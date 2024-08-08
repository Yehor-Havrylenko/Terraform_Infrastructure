provider "aws" {
  region = "us-east-1"
}
terraform{
  backend "s3" {
  }
}

locals {
  certificate_domains = {
    for k, cert in aws_acm_certificate.cert :
    k => flatten([for opt in cert.domain_validation_options : {
      name   = opt.resource_record_name
      type   = opt.resource_record_type
      value  = opt.resource_record_value
    }])[0]
  }
}

resource "aws_acm_certificate" "cert" {
  for_each = var.custom_domain_names

  domain_name               = each.value
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    managed = "Terraform"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = var.custom_domain_names

  zone_id = var.route53_zone_id
  name    = local.certificate_domains[each.key].name
  type    = local.certificate_domains[each.key].type
  ttl     = 60
  records = [local.certificate_domains[each.key].value]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  for_each = var.custom_domain_names

  certificate_arn         = aws_acm_certificate.cert[each.key].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}

resource "aws_cloudfront_function" "cors_function" {
  for_each = var.api_endpoints
  name    = "cors-options-${replace(each.key, ".{domain}", "")}"
  runtime = "cloudfront-js-2.0"
  code    = file("cors.js")
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  for_each = var.api_endpoints

  origin {
    domain_name = replace(each.value, "https://", "")
    origin_id   = each.value

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }

    connection_attempts = 3
    connection_timeout  = 10
  }

  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"
  comment             = "CloudFront distribution for ${each.key}"
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = each.value

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.cors_function[each.key].arn
    }
    cache_policy_id             = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id    = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

#  web_acl_id = ""//WAF

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert[each.key].arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  aliases = [each.key]

  tags = {
    managed = "Terraform"
  }
}

resource "aws_route53_record" "api_record" {
  for_each = var.custom_domain_names
  zone_id  = var.route53_zone_id
  name     = each.value
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distribution[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}
