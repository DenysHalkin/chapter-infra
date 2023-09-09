include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "../../_tf-modules/frontend-web-app"
}

dependencies {
  paths = ["../../shared/acm"]
}

dependency "acm" {
  config_path = "${get_terragrunt_dir()}/../../shared/acm"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  common_tags = {
    Tier        = "web"
    Environment = local.env_name
  }
}

inputs = {
  project      = include.root.locals.project
  env_name     = local.env_name
  region_alias = include.root.locals.region_alias

  web_app_subdomain   = "dev"
  web_app_domain_name = "chapter-web.com"
  acm_certificate_arn = dependency.acm.outputs.acm_certificate_arn

  common_tags = local.common_tags
}