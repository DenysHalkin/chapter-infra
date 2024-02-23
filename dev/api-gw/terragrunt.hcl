//include "root" {
//  path   = find_in_parent_folders()
//  expose = true
//}
//
//terraform {
//  source  = "tfr://registry.terraform.io/terraform-aws-modules/apigateway-v2/aws?version=2.2.2"
//}
//
////dependencies {
////  paths = ["../../shared/acm"]
////}
////
////dependency "acm" {
////  config_path = "${get_terragrunt_dir()}/../../shared/acm"
////}
//
//locals {
//  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
//  env_name = local.env_vars.locals.env_name
//
//  common_tags = {
//    Tier        = "web"
//    Environment = local.env_name
//  }
//}
//
//inputs = {
//
//  name          = "${include.root.locals.project}-${local.env_name}-http-api-${include.root.locals.region_alias}"
//  description   = "HTTP API for ${title(include.root.locals.project)} ${title(local.env_name)} environment"
//  protocol_type = "HTTP"
//
//  create_api_domain_name       = false
//  disable_execute_api_endpoint = false
//
//  /* Start of quick create */
//  route_key = "ANY /"
//  #credentials_arn = credentials_arn
//  target = "arn:aws:lambda:us-west-2:781931727887:function:test"
//  /* End of quick create */
//
////
////  cors_configuration = {
////    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
////    allow_methods = ["*"]
////    allow_origins = ["*"]
////  }
//
////  integrations = {
////    "ANY /" = {
////      lambda_arn             = module.lambda_function.lambda_function_arn
////      payload_format_version = "2.0"
////      timeout_milliseconds   = 12000
////    }
////  }
//
//  tags = local.common_tags
//}