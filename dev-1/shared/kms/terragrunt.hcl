include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/kms/aws?version=2.0.0"
}

locals {
  common_tags = {
    Environment = "shared"
  }
}

inputs = {
  aliases                 = ["${include.root.locals.project}/shared"]
  deletion_window_in_days = 7
  description             =  "Shared KMS for ${title(include.root.locals.project)} project"
  enable_key_rotation     = true
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = false

  tags = local.common_tags
}