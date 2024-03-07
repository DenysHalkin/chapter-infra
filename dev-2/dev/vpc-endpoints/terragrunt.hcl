include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws//modules/vpc-endpoints?version=5.1.2"
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  common_tags = {
    Environment = local.env_name
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  create_security_group = true
  security_group_name        = "${include.root.locals.project}-${local.env_name}-vpce-sg"
  security_group_description = "${title(include.root.locals.project)} ${title(local.env_name)} VPC endpoint security group"

  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block]
    },
    outbound_any = {
      description = "Allow any outbound traffic"
      cidr_blocks = ["0.0.0.0/0"]
      type              = "egress"
      to_port           = 0
      protocol          = "-1"
      from_port         = 0
    }
  }

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = dependency.vpc.outputs.private_route_table_ids

      tags = { Name = "${include.root.locals.project}-${local.env_name}-s3-vpce" }
    },
//    ecr_dkr = {
//      service             = "ecr.dkr"
//      private_dns_enabled = true
//      subnet_ids          =  dependency.vpc.outputs.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-ecr-dkr-vpce" }
//    },
//    logs = {
//      service             = "logs"
//      private_dns_enabled = true
//      subnet_ids          = dependency.vpc.outputs.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-logs-vpce" }
//    },
//    ecs = {
//      service             = "ecs"
//      private_dns_enabled = true
//      subnet_ids          = dependency.vpc.outputs.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-ecs-vpce" }
//    },
//    ecs-agent = {
//      service             = "ecs-agent"
//      private_dns_enabled = true
//      subnet_ids          = dependency.vpc.outputs.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-ecs-agent-vpce" }
//    },
//    ecs-telemetry = {
//      service             = "ecs-telemetry"
//      private_dns_enabled = true
//      subnet_ids          = dependency.vpc.outputs.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-ecs-telemetry-vpce" }
//    }
  }

  tags = local.common_tags
}