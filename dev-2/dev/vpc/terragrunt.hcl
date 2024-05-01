include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.1.2"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  vpc_cidr           = "10.58.0.0/20"
  public_subnets     = ["10.58.0.0/23", "10.58.2.0/23"]
  private_subnets    = ["10.58.4.0/23", "10.58.6.0/23"]
  database_subnets   = ["10.58.8.0/23", "10.58.10.0/23"]
  availability_zones = ["${include.root.locals.aws_region}a", "${include.root.locals.aws_region}b"]

  common_tags = {
    Environment = local.env_name
  }
}

inputs = {
  name = "${include.root.locals.project}-${local.env_name}-vpc"

  azs = local.availability_zones

  cidr = local.vpc_cidr

  enable_dhcp_options      = true
  dhcp_options_domain_name = "${include.root.locals.aws_region}.compute.internal"

  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  enable_nat_gateway     = false
  one_nat_gateway_per_az = false

  # Public subnet
  public_subnets               = local.public_subnets
  map_public_ip_on_launch      = false
  public_dedicated_network_acl = false

  public_subnet_tags = {
    Tier = "web"
  }

  # Private subnets
  private_subnets               = local.private_subnets
  private_dedicated_network_acl = false
  private_subnet_tags = {
    Tier = "application"
  }

  # Database subnets
  database_subnets                       =  local.database_subnets
  create_database_subnet_group           = false
  database_dedicated_network_acl         = false

  database_subnet_tags = {
    Tier = "database"
  }

  create_database_subnet_group    = false
  create_redshift_subnet_group    = false
  create_elasticache_subnet_group = false

  tags = local.common_tags
}