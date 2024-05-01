variable "tags" {
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

variable "http_api_gw" {
  description = "API Gateways params"
  type = object({
    alb_listener_arn    = string #ALB listener arn for integration with API Gateway
    domain_name         = string
    acm_certificate_arn = string
  })
}

variable "ws_api_gw" {
  description = "WEBSOCKET API Gateways params"
  type = object({
    alb_listener_arn    = string #ALB listener arn for integration with API Gateway
    domain_name         = string
    acm_certificate_arn = string
  })
}

variable "vpc" {
  description = "VPC vars"
  type = object({
    vpc_id          = string
    private_subnets = list(string)
  })
}