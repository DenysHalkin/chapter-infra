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

variable "vpc" {
  description = "VPC vars"
  type = object({
    vpc_id          = string
    private_subnets = list(string)
  })
}