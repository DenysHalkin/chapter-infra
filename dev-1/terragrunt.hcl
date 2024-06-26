terraform {
  before_hook "tflint" {
    commands = ["apply", "plan"]
    execute = ["tflint" , "--terragrunt-external-tflint", "--minimum-failure-severity=error"]
  }
}

locals {
  project                = "chapter"
  aws_profile            = "chapter"
  acc_id                 = "781931727887"
  terraform_state_bucket = "chapter-terraform-state-usw2"
  aws_region             = "us-west-2"
  owner                  = "denis.galkin.91@gmail.com"

  region_alias = join("", [replace(regex("^.*-[a-z]{1}", local.aws_region), "-", ""), regex("[0-9]$", local.aws_region)])
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
    region  = local.aws_region
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
    profile = local.aws_profile
  }
}

# provider.tf
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.aws_profile}"

  default_tags {
    tags = {
      Project = "${local.project}"
      Owner   = "${local.owner}"
    }
  }
}
EOF
}

# versions.tf
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = "= 1.8.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.15.0"
    }
  }
}
EOF
}