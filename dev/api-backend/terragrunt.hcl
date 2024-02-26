include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "../../_tf-modules/api-backend"
}

dependencies {
  paths = ["../vpc", "../api-backend-params"]
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"
}

dependency "api_backend_params" {
  config_path = "${get_terragrunt_dir()}/../api-backend-params"
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
  project      = include.root.locals.project
  env_name     = local.env_name
  region_alias = include.root.locals.region_alias
  common_tags  = local.common_tags

  vpc = {
    vpc_id          = dependency.vpc.outputs.vpc_id
    vpc_cidr_block  = dependency.vpc.outputs.vpc_cidr_block
    public_subnets  = dependency.vpc.outputs.public_subnets
    private_subnets = dependency.vpc.outputs.private_subnets
  }

  asg = {
    autoscaling = {
      min_size         = 0
      max_size         = 1
      desired_capacity = 1
    }
    launch_template = {
      image_id               = "ami-08cdfdb2b57f8ee2b"
      instance_type          = "t2.micro"
      enable_monitoring      = false
    }
  }

  ecs = {
    container = {
      image         = "856033197975.dkr.ecr.eu-central-1.amazonaws.com/chapter-dev-api:latest"
      cpu           = 1000
      memory        = 900
      desired_count = 1
      secrets       = dependency.api_backend_params.outputs.created_params
    }
  }
}
