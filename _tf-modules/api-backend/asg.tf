data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc.vpc_id
}

module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name            = "${var.project}-${var.env_name}-api-backend-asg-${var.region_alias}"
  use_name_prefix = false
  description     = "A security group for ${title(var.project)} ${var.env_name} ECS clsuter EC2 capacity provider"
  vpc_id          = var.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = data.aws_security_group.default.id
    }
  ]

  # List of IPv4 CIDR ranges to use on all egress rules
  egress_cidr_blocks = ["0.0.0.0/0"]

  # List of egress rules to create by name
  egress_rules = ["all-all"]
  tags         = var.common_tags
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.3.0"

  # Autoscaling group
  name                = "${var.project}-${var.env_name}-ecs-api-backend-${var.region_alias}"
  use_name_prefix     = false
  security_groups     = [module.asg_sg.security_group_id]
  vpc_zone_identifier = var.vpc.private_subnets

  min_size                  = var.asg.autoscaling.min_size
  max_size                  = var.asg.autoscaling.max_size
  desired_capacity          = var.asg.autoscaling.desired_capacity
  capacity_rebalance        = true
  default_cooldown          = 300
  default_instance_warmup   = 120
  disable_api_stop          = false
  disable_api_termination   = false
  health_check_type         = "EC2"
  health_check_grace_period = 120
  scaling_policies          = {}
  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay             = 120
      checkpoint_percentages       = [25, 50, 100]
      min_healthy_percentage       = 100
      auto_rollback                = true
      scale_in_protected_instances = "Refresh"
      standby_instances            = "Terminate"
    }
  }
  warm_pool                       = {}
  launch_template_name            = "${var.project}-${var.env_name}-ecs-api-backend-${var.region_alias}"
  launch_template_use_name_prefix = false
  launch_template_description     = "${title(var.project)} ${var.env_name} template for ECS EC2 capacity provider"
  update_default_version          = true
  image_id                        = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type                   = var.asg.launch_template.instance_type
  enable_monitoring               = var.asg.launch_template.enable_monitoring

  user_data = base64encode(templatefile("${path.module}/asg-userdata.sh", {
    cluster_name = local.cluster_name
    common_tags  = jsonencode(var.common_tags)
  }))

  create_iam_instance_profile = true
  iam_role_use_name_prefix    = false
  iam_role_name               = "${var.project}-${var.env_name}-ecs-ec2-${var.region_alias}"
  iam_role_description        = "${title(var.project)} ${var.env_name} Role for ECS EC2 capacity provider"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  iam_role_tags = var.common_tags

  ebs_optimized = false

  network_interfaces = [{
    delete_on_termination       = true
    associate_public_ip_address = true
  }]

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"

    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  maintenance_options = {
    auto_recovery = "disabled"
  }

  termination_policies = ["OldestInstance", "OldestLaunchTemplate"]

  create_schedule = false

  autoscaling_group_tags = merge(var.common_tags, {
    AmazonECSManaged = true
  })
}