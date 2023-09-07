locals {
  common_tags = {
    Tier        = "web"
    Environment = var.env_name
  }
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

variable "web_app_domain_name" {
  description = "Application domain name"
  type        = string
}

variable "r53_domain_name" {
  description = "Route 53 zone domain name"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate arn for Cloudfront"
  type        = string
}