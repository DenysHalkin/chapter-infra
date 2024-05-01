include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/acm/aws?version=4.3.2"
}

dependencies {
  paths = ["../../../dev-1/shared/r53/chapter-web.com-zones", "../acm"]
}

dependency "r53_zone" {
  config_path = "${get_terragrunt_dir()}/../../../dev-1/shared/r53/chapter-web.com-zones"
}

dependency "acm" {
  config_path = "${get_terragrunt_dir()}/../acm"
}

locals {
  common_tags = {
    Environment = "shared"
  }
}

inputs = {
  create_certificate          = false
  create_route53_records_only = true
  validation_method           = "DNS"

  zone_id               = dependency.r53_zone.outputs.route53_zone_zone_id["chapter-web.com"]
  distinct_domain_names = dependency.acm.outputs.distinct_domain_names

  acm_certificate_domain_validation_options = dependency.acm.outputs.acm_certificate_domain_validation_options

  tags = local.common_tags
}

# Route53 records in other aws account
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "us-west-2"
  profile = "chapter"

  default_tags {
    tags = {
      Project = "${include.root.locals.project}"
      Owner   = "${include.root.locals.owner}"
    }
  }
}
EOF
}
