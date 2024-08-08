variable "domain_name" {
  description = "The domain name for Route 53 hosted zone"
  type        = string
}

variable "subdomain" {
  description = "The subdomain name"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for ACM"
  type        = list(string)
  default     = []
}

variable "web_acl_id" {
  description = "The WAF ARN"
  type        = string
}

variable "cache_policy_id" {
  description = "ID of the cache policy"
  type        = string
}

variable "origin_request_policy_id" {
  description = "ID of the origin request policy"
  type        = string
}

variable "distributions" {
  description = "Map of distributions with their settings"
  type = map(object({
    aliases                    : list(string)
    comment                    : string
    bucket_name                : string
    bucket_access_identity     : string
    response_headers_policy_id : string
  }))
}

variable "s3_buckets" {
  description = "Map of S3 buckets with their settings"
  type = map(object({
    bucket_name   : string
    force_destroy : bool
  }))
}
