variable "api_endpoints" {
  description = "Map of API names to their endpoints"
  type        = map(string)
}

variable "custom_domain_names" {
  description = "Map of API names to their custom domain names"
  type        = map(string)
}

variable "certificate_arn_us_east_1" {
  description = "ARN of the SSL certificate in us-east-1 for CloudFront"
  type        = string
}

variable "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  type        = string
}
