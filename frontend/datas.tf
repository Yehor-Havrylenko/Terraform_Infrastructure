data "aws_route53_zone" "this" {
  name         = local.domain_name
  private_zone = false
}
data "aws_canonical_user_id" "current" {}
