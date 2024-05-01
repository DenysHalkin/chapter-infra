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

variable "app_domain_name" {
  description = "Application domain name"
  type        = string
}

variable "app_subdomain" {
  description = "Application subdomain name"
  type        = string
}

variable "api_alb_domain_name" {
  description = "API backend application ALB domain name"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate arn for Cloudfront"
  type        = string
}