output "cloudfront_distribution_ids" {
  value = { for k, v in aws_cloudfront_distribution.cf_distribution : k => v.id }
}

output "cloudfront_domain_names" {
  value = { for k, v in aws_cloudfront_distribution.cf_distribution : k => v.domain_name }
}

output "route53_records" {
  value = { for k, v in aws_route53_record.api_record : k => v.name }
}
