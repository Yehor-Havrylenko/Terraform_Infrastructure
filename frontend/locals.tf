locals {
  domain = var.domain_name

  # Removing trailing dot from domain - just to be sure :)
  domain_name = trimsuffix(local.domain, ".")

  domain_replaced = replace(local.domain, ".", "-")

  subdomain = var.subdomain
}
