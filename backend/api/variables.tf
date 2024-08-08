variable "region" {
  description = "AWS region"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "vpc_link_name" {
  description = "Name of the VPC Link"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "elb_listener_arn" {
  description = "ARN of the ELB listener"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 zone ID"
  type        = string
}

variable "api" {
  description = "API configuration"
  type = map(object({
    domain_name = string
    header      = string
  }))
}

