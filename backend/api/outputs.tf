output "custom_domain_names" {
  description = "Custom domain names for APIs"
  value = {
    for key, value in var.api : value.domain_name => value.domain_name
  }
}
output "api_endpoints" {
  value = {
    for k, v in var.api :
    v.domain_name => aws_apigatewayv2_api.http_api[k].api_endpoint
  }
}

