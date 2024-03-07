include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/acm/aws?version=4.3.2"
}

dependencies {
  paths = ["../r53/chapter-web.com-zones"]
}

dependency "r53_zone" {
  config_path = "${get_terragrunt_dir()}/../r53/chapter-web.com-zones"
}

locals {
  common_tags = {
    Environment = "shared"
  }
}

inputs = {
  domain_name               = "chapter-web.com"
  zone_id                   = dependency.r53_zone.outputs.route53_zone_zone_id["chapter-web.com"]
  subject_alternative_names = ["*.chapter-web.com"]

  tags = local.common_tags
}

# ACM certificate in us-east-1 required for Cloudfront
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "us-east-1"
  profile = "${include.root.locals.aws_profile}"

  default_tags {
    tags = {
      Project = "${include.root.locals.project}"
      Owner   = "${include.root.locals.owner}"
    }
  }
}
EOF
}
