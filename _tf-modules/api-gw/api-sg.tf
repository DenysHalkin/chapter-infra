module "api_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name            = "${var.project}-${var.env_name}-api-${var.region_alias}"
  use_name_prefix = false
  description     = "API Gateway group"
  vpc_id          = var.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]
}