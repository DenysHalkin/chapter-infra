include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "../../../chapter-infra-tf-modules/frontend-web-app"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name
}

inputs = {
  project      = include.root.locals.project
  env_name     = local.env_name
  region_alias = include.root.locals.region_alias
}