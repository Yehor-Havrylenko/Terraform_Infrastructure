output "aws_route53_zone_id" {
  description = "Route Hosted Zone ID"
  value       = data.aws_route53_zone.this.zone_id
}

output "s3_bucket_ids" {
  description = "S3 bucket IDs"
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "cloudfront_distribution_ids" {
  description = "CloudFront Distribution IDs"
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.id }
}
