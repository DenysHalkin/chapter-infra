module "ws_api" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "3.1.1"

  name          = "${var.project}-${var.env_name}-ws-api-${var.region_alias}"
  description   = "WEBSOCKET API Gateway"
  protocol_type = "WEBSOCKET"

  domain_name                 = var.ws_api_gw.domain_name
  domain_name_certificate_arn = var.ws_api_gw.acm_certificate_arn

//  integrations = {
//    "ANY /" = {
//      connection_type    = "VPC_LINK"
//      vpc_link           = "default"
//      integration_uri    = var.ws_api_gw.alb_listener_arn
//      integration_type   = "HTTP_PROXY"
//      integration_method = "ANY"
//    }
//  }
//
//  vpc_links = {
//    default = {
//      name               = "${var.project}-${var.env_name}-ws-api-${var.region_alias}"
//      security_group_ids = [module.api_sg.security_group_id]
//      subnet_ids         = var.vpc.private_subnets
//    }
//  }

  tags = var.tags
}