module "http_api" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "3.1.1"

  name          = "${var.project}-${var.env_name}-http-api-${var.region_alias}"
  description   = "HTTP API Gateway"
  protocol_type = "HTTP"

  domain_name                 = var.http_api_gw.domain_name
  domain_name_certificate_arn = var.http_api_gw.acm_certificate_arn

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  integrations = {
    "ANY /" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "default"
      integration_uri    = var.http_api_gw.alb_listener_arn
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"
    }
  }

  vpc_links = {
    default = {
      name               = "${var.project}-${var.env_name}-http-api-${var.region_alias}"
      security_group_ids = [module.api_sg.security_group_id]
      subnet_ids         = var.vpc.private_subnets
    }
  }

  tags = var.tags
}