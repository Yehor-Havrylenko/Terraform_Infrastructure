region                     = "eu-central-1"
certificate_arn            = ""//acm certificate
vpc_link_name              = "vpc-link"
subnet_ids                 = ["subnet-1", "subnet-2"]
security_group_ids         = ["sg-1"]
route53_zone_id            = ""

api = {
  example = {
    domain_name = "example.net"
    header = ""
  }
}
