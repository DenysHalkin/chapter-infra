include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../_tf-modules/ssm-params"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  common_tags = {
    Tier        = "Application"
    Environment = local.env_name
  }
}

inputs = {
  params_prefix    =  "/${include.root.locals.project}/${local.env_name}"
  sops_source_file = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/secrets.yaml"

  tags = local.common_tags
}

# versions.tf
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = "= 1.5.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    sops = {
      source  = "carlpett/sops"
      version = "= 1.0.0"
    }
  }
}
EOF
}