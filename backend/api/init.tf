provider "aws" {
  region = "eu-central-1"
}

terraform{
  backend "s3" {
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  for_each      = var.api
  name          = each.key
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["*"]
    max_age           = 0
  }

  tags = {
    managed = "Terraform"
  }
}

resource "aws_apigatewayv2_stage" "default_stage" {
  for_each    = aws_apigatewayv2_api.http_api
  api_id      = each.value.id
  name        = "$default"
  auto_deploy = true

  tags = {
    managed = "Terraform"
  }
}

resource "aws_acm_certificate" "api_cert" {
  for_each = var.api

  domain_name       = each.value.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for domain_key, domain_value in aws_acm_certificate.api_cert : 
    domain_key => domain_value
  }

  zone_id = var.route53_zone_id

  name    = tolist(each.value.domain_validation_options)[0].resource_record_name
  type    = tolist(each.value.domain_validation_options)[0].resource_record_type
  records = [tolist(each.value.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_apigatewayv2_domain_name" "api_domain_name" {
  for_each    = var.api
  domain_name = each.value.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert[each.key].arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  for_each    = aws_apigatewayv2_api.http_api
  api_id      = each.value.id
  domain_name = aws_apigatewayv2_domain_name.api_domain_name[each.key].domain_name
  stage       = aws_apigatewayv2_stage.default_stage[each.key].name
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = var.vpc_link_name
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  tags = {
    managed = "Terraform"
  }
}

resource "aws_apigatewayv2_integration" "lb_integration" {
  for_each           = aws_apigatewayv2_api.http_api
  api_id             = each.value.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = var.elb_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id
  integration_method = "ANY"

  request_parameters = {
    "overwrite:path" = var.api[each.key].header
  }
}

resource "aws_apigatewayv2_route" "default_route" {
  for_each  = aws_apigatewayv2_api.http_api
  api_id    = each.value.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lb_integration[each.key].id}"
}
