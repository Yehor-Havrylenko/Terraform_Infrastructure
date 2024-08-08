domain_name = ".net"
subdomain   = "example"

subject_alternative_names = []

# S3 bucket settings
s3_buckets = {
  main = {
    bucket_name   = "example.net"
    force_destroy = false
  }
}

# CloudFront settings
distributions = {
  main = {
    aliases                    = ["example.net"]
    comment                    = "example CDN"
    bucket_name                = "example.net"
    bucket_access_identity     = "example Bucket access"
    response_headers_policy_id = "f9cd8207-8b8a-4c84-8c5e-2da5126dbaa8"
  }
}

cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
web_acl_id               = "" //waf id