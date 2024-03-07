include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/acm/aws?version=4.3.2"
}

locals {
  common_tags = {
    Environment = "shared"
  }
}

inputs = {
  domain_name               = "chapter-web.com"
  subject_alternative_names = ["*.chapter-web.com"]

  validation_method       = "DNS"
  create_route53_records  = false
  wait_for_validation     = false

  tags = local.common_tags
}
