include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/rds/aws?version=6.5.5"
}

dependencies {
  paths = ["../vpc", "../rds-sg"]
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"
}

dependency "rds_sg" {
  config_path  = "${get_terragrunt_dir()}/../rds-sg"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  common_tags = {
    Tier        = "Data"
    Environment = local.env_name
  }
}

inputs = {
  identifier = "${include.root.locals.project}-${local.env_name}-${include.root.locals.region_alias}"

  snapshot_identifier = "${include.root.locals.project}-${local.env_name}-db-${include.root.locals.region_alias}"

  engine               = "postgres"
  engine_version       = "15.5"
  family               = "postgres15" # DB parameter group
  major_engine_version = "15"         # DB option group
  instance_class       = "db.t3.micro"

  storage_encrypted     = false
  allocated_storage     = 20
  max_allocated_storage = 30

  username                    = "postgres"
  manage_master_user_password = false

  vpc_security_group_ids = [dependency.rds_sg.outputs.security_group_id]

  create_db_subnet_group          = true
  db_subnet_group_name            = "${include.root.locals.project}-${local.env_name}-${include.root.locals.region_alias}"
  db_subnet_group_use_name_prefix = false
  db_subnet_group_description     = "DB subnet group for ${include.root.locals.project} ${local.env_name}"
  subnet_ids                      = dependency.vpc.outputs.database_subnets

  parameter_group_name            = "${include.root.locals.project}-${local.env_name}-${include.root.locals.region_alias}"
  parameter_group_use_name_prefix = false
  parameter_group_description     = "DB paramater group for ${include.root.locals.project} ${local.env_name}"
  parameters                      = []

  option_group_name            = "${include.root.locals.project}-${local.env_name}-${include.root.locals.region_alias}"
  option_group_use_name_prefix = false
  option_group_description     = "DB option group for ${include.root.locals.project} ${local.env_name}"
  options                      = []

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 1

  apply_immediately = true

  tags = local.common_tags
}

