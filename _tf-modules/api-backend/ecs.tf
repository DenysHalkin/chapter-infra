locals {
  cluster_name = "${var.project}-${var.env_name}-${var.region_alias}"

  container_name = "api-backend"
  container_port = 3000
  desired_count  = 2

  region = "eu-central-1"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.9.1"

  #Cluster
  cluster_name = local.cluster_name

  cluster_settings = [
    {
      name  = "containerInsights"
      value = "disabled"
    }
  ]

  # Capacity provider
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    default_ec2 = {
      auto_scaling_group_arn         = module.asg.autoscaling_group_arn
      managed_termination_protection = "DISABLED"

      managed_scaling = {
        instance_warmup_period    = 60
        maximum_scaling_step_size = 1
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 100
      }

      default_capacity_provider_strategy = {
        weight = 100
        base   = 2
      }
    }
  }

  services = {
    (local.container_name) = {

      # Task execution IAM role
      create_task_exec_iam_role          = true
      task_exec_iam_role_use_name_prefix = false
      task_exec_iam_role_name            = "${var.project}-${var.env_name}-${local.container_name}-ecs-task-exec-${var.region_alias}"
      task_exec_iam_role_description     = "Tast execution role for ${(local.container_name)} ECS service ${title(var.project)} ${var.env_name} environement"
      task_exec_iam_role_policies        = {}

      # Task execution IAM role policy
      create_task_exec_policy  = true
      task_exec_secret_arns    = ["arn:aws:secretsmanager:*:*:secret:*"]
      task_exec_ssm_param_arns = ["arn:aws:ssm:*:*:parameter/*"]
      task_exec_iam_statements = {}

      # Task IAM role
      tasks_iam_role_name            = "${var.project}-${var.env_name}-${local.container_name}-ecs-task-${var.region_alias}"
      tasks_iam_role_use_name_prefix = false
      tasks_iam_role_description     = "Tast role for ${(local.container_name)} ECS service ${title(var.project)} ${var.env_name} environement"
      tasks_iam_role_policies        = {}
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      //      subnet_ids = var.vpc.private_subnets
      //
      //      # Security group
      //      create_security_group          = true
      //      security_group_use_name_prefix = false
      //      security_group_name            = "${var.project}-${var.env_name}-api-backend-ecs-service-${var.region_alias}"
      //      security_group_description     = "SG for ${(local.container_name)} ECS service ${title(var.project)} ${var.env_name} environement"
      //
      //      security_group_rules = {
      //        alb_http_ingress = {
      //          type                     = "ingress"
      //          from_port                = local.container_port
      //          to_port                  = local.container_port
      //          protocol                 = "tcp"
      //          description              = "Service port"
      //          source_security_group_id = module.asg_sg.security_group_id
      //        }
      //      }

      # Task Definition
      requires_compatibilities = ["EC2"]

      capacity_provider_strategy = {
        default_ec2 = {
          //noinspection HILUnresolvedReference
          capacity_provider = module.ecs.autoscaling_capacity_providers["default_ec2"].name
          weight            = 1
          base              = 2
        }
      }

      cpu          = var.ecs.container.cpu
      memory       = var.ecs.container.memory
      network_mode = "host"

      enable_autoscaling                 = false
      desired_count                      = var.ecs.container.desired_count
      deployment_maximum_percent         = 200
      deployment_minimum_healthy_percent = 0

      # Container definition(s)
      container_definitions = {
        (local.container_name) = {
          cpu       = 0
          essential = true
          image     = var.ecs.container.image
          port_mappings = [
            {
              name          = (local.container_name)
              containerPort = local.container_port
              hostPort      = local.container_port
              protocol      = "tcp"
            }
          ]

          secrets = var.ecs.container.secrets

          //          health_check = {
          //            command = ["CMD-SHELL", "curl -f http://localhost:${local.container_port}/health || exit 1"]
          //          }
          //

          readonly_root_filesystem = false

          enable_cloudwatch_logging              = true
          create_cloudwatch_log_group            = true
          cloudwatch_log_group_name              = "/aws/ecs/${local.cluster_name}/${local.container_name}"
          cloudwatch_log_group_retention_in_days = 1

          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-region        = local.region
              awslogs-group         = "/aws/ecs/${local.cluster_name}/${local.container_name}"
              awslogs-stream-prefix = local.container_name
            }
          }
        }
      }
      //      load_balancer = {
      //        service = {
      //          target_group_arn = module.alb.target_groups["api"].arn
      //          container_name   = local.container_name
      //          container_port   = local.container_port
      //        }
      //      }
      //
    }
  }

  tags = var.common_tags
}