include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/security-group/aws?version=4.17.1"
}

dependencies {
  paths = ["../vpc", "../api-backend"]
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"
}

dependency "api_backend" {
  config_path = "${get_terragrunt_dir()}/../api-backend"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  common_tags = {
    Tier        = "Data"
    Environment = local.env_name
  }
}

inputs = {
  name = "${include.root.locals.project}-${local.env_name}-db-sg-${include.root.locals.region_alias}"

  # Description of security group
  description = "Security group that controls access to database"

  # Instruct Terraform to revoke all of the Security Groups attached ingress and egress rules before deleting the rule itself. Enable for EMR.
  revoke_rules_on_delete = true

  # Whether to use name_prefix or fixed name. Should be true to able to update security group name after initial creation
  use_name_prefix = false

  # ID of the VPC where to create security group
  vpc_id = dependency.vpc.outputs.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = dependency.api_backend.outputs.asg_sg.security_group_id
    }
  ]

  # List of IPv4 CIDR ranges to use on all egress rules
  egress_cidr_blocks = ["0.0.0.0/0"]

  # List of egress rules to create by name
  egress_rules = ["all-all"]

  tags = local.common_tags
}