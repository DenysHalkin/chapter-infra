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