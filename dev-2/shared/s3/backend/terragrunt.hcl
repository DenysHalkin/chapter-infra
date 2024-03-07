include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/s3-bucket/aws?version=3.15.1"
}

locals {
  common_tags = {
    Environment = "shared"
  }
}

inputs = {
  bucket = include.root.locals.terraform_state_bucket

  attach_deny_insecure_transport_policy  = true
  attach_require_latest_tls_policy       = true
  attach_deny_unencrypted_object_uploads = true

  attach_policy  = true
  policy         = jsondecode(templatefile("${get_parent_terragrunt_dir()}/${path_relative_to_include()}/policy.json", {
    acc_id = include.root.locals.acc_id
  }))

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = "arn:aws:kms:${include.root.locals.aws_region}:${include.root.locals.acc_id}:alias/aws/s3"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "keep_only_2_versions_of_files"
      enabled = true

      filter = {
        prefix = ""
      }

      noncurrent_version_expiration = {
        newer_noncurrent_versions = 2
        days                      = 1
      }
    }
  ]

  versioning = {
    status     = true
    mfa_delete = false
  }

  tags = local.common_tags
}

# Generate backend.tf file with remote state configuration
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }
}