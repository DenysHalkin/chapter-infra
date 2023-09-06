locals {
  project                = "safekeep"
  aws_profile            = "cccis-safekeep-exp"
  account_alias          = "exp"
  terraform_state_bucket = "cccis-safekeep-exp-terraform-state-ue1"
  account_id             = "812406898539"
  org                    = "ccc"
  buseg                  = "safekeep"

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region

  aws_region_alias = join("", [replace(regex("^.*-[a-z]{1}", local.aws_region), "-", ""), regex("[0-9]$", local.aws_region)])
}

# Generate backend.tf file with remote state configuration
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket  = local.terraform_state_bucket
    region  = "us-east-1"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
    profile = local.aws_profile
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.aws_profile}"

  default_tags {
    tags = {
      "Assigned VP"        = "Ahmed Abulsouror"
      Horizontal           = "APD"
      Vertical             = "Insurance"
      "CCC Product Family" = "Subrogation"
      "Application"        = var.application
    }
  }
}

variable "application" {
  description  = "The aws region where should be aws resources"
  type         = string
  default      = "Safekeep Shared Services"
}
EOF
}

# Generate versions file
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = "= 1.4.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.3.0"
    }
  }
}
EOF
}