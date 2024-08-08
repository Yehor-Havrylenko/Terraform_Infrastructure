
resource "aws_acm_certificate" "this" {
  provider = aws.us

  domain_name               = "${var.subdomain}.${var.domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  tags = {
    Name    = var.domain_name
    managed = "Terraform"
  }
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.us

  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  provider = aws.us

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
resource "aws_cloudfront_origin_access_identity" "this" {
  for_each = var.distributions

  comment = "${each.value.comment} Origin Access Identity"
}

resource "aws_cloudfront_distribution" "this" {
  for_each = var.distributions

  provider = aws.us

  origin {
    domain_name = "${each.value.bucket_name}.s3.eu-central-1.amazonaws.com"
    origin_id   = "s3-${each.value.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this[each.key].cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = each.value.comment
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = each.value.aliases

  default_cache_behavior {
    target_origin_id       = "s3-${each.value.bucket_name}"
    viewer_protocol_policy = "https-only"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    
    default_ttl = 86400
    max_ttl     = 31536000
    min_ttl     = 0

    cache_policy_id             = var.cache_policy_id
    origin_request_policy_id    = var.origin_request_policy_id
    response_headers_policy_id  = each.value.response_headers_policy_id
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.this.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.web_acl_id

  tags = {
    Name = each.value.comment
    managed = "Terraform"
  }
}

resource "aws_route53_record" "this" {
  for_each = var.distributions

  provider = aws.us

  zone_id = data.aws_route53_zone.this.zone_id

  name = each.value.aliases[0]
  type = "A"
  alias {
    name                   = aws_cloudfront_distribution.this[each.key].domain_name
    zone_id                = data.aws_route53_zone.this.zone_id  # AWS Global CloudFront Hosted Zone ID
    evaluate_target_health = false
  }
}