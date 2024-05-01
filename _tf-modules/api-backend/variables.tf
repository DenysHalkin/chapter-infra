variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "env_name" {
  description = "Environment name: dev, stage, prod"
  type        = string
}

variable "region_alias" {
  description = "Region alias"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate arm for HTTPS ALB listener"
  type        = string
}

variable "route53_records" {
  description = "Map of Route53 records to create. Each record map should contain `zone_id`, `name`, and `type`"
  type        = any
  default     = {}
}

variable "vpc" {
  description = "VPC vars"
  type = object({
    vpc_id          = string
    vpc_cidr_block  = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}