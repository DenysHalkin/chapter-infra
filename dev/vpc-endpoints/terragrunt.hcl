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
//    logs = {
//      service             = "logs"
//      private_dns_enabled = true
//      #subnet_ids          = ["subnet-12345678", "subnet-87654321"]
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-logs-vpce" }
//    },
//    lambda = {
//      service          = "lambda"
//      #subnet_ids
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-lambda-vpce" }
//    },
//    ecr_api = {
//      service             = "ecr.api"
//      private_dns_enabled = true
//      #subnet_ids          = module.vpc.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-ecr-api-vpce" }
//
//    },
//    ecr_dkr = {
//      service             = "ecr.dkr"
//      private_dns_enabled = true
//      #subnet_ids          = module.vpc.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-ecr-dkr-vpce" }
//    },
//    rds = {
//      service             = "rds"
//      private_dns_enabled = true
//      #subnet_ids          = module.vpc.private_subnets
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-rds-vpce" }
//    }
//    sns = {
//      service             = "sns"
//      private_dns_enabled = true
//      #subnet_ids          = ["subnet-12345678", "subnet-87654321"]
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-sns-vpce" }
//    },
//    sqs = {
//      service             = "sqs"
//      private_dns_enabled = true
//      #subnet_ids          = ["subnet-12345678", "subnet-87654321"]
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-sqs-vpce" }
//    },
//    ec2 = {
//      service             = "ec2"
//      private_dns_enabled = true
//      #subnet_ids          = ["subnet-12345678", "subnet-87654321"]
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-ec2-vpce" }
//    }
//    execute-api = {
//      service             = "execute-api"
//      private_dns_enabled = true
//      #subnet_ids          = ["subnet-12345678", "subnet-87654321"]
//
//      tags = { Name = "${include.root.locals.project}-${local.env_name}-execute-api-vpce" }
//    }
  }

  tags = local.common_tags
}