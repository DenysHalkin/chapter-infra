module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = "${var.project}-${var.env_name}-pb-alb-${var.region_alias}"

  load_balancer_type = "application"

  vpc_id  = var.vpc.vpc_id
  subnets = var.vpc.public_subnets

  enable_deletion_protection = false

  # Security Group
  security_group_use_name_prefix = false

  security_group_tags = {
    Name = "${var.project}-${var.env_name}-pb-alb-${var.region_alias}"
  }

  security_group_ingress_rules = {
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc.vpc_cidr_block
    }
  }

  listeners = {
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = "arn:aws:acm:eu-central-1:856033197975:certificate/2fb7be3c-2cb7-4e97-95ec-7bdc007e6624" #module.acm.acm_certificate_arn

      forward = {
        target_group_key = local.container_name
      }
    }

    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  target_groups = {
    (local.container_name) = {
      name                              = "${var.project}-${var.env_name}-${local.container_name}-tg-${var.region_alias}"
      backend_protocol                  = "HTTP"
      port                              = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/docs"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
      create_attachment = false
    }
  }

  tags = var.common_tags
}