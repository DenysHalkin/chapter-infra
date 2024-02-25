variable "asg" {
  type = object({
    autoscaling = object({
      min_size         = number # The minimum size of the autoscaling group
      max_size         = number # The maximum size of the autoscaling group
      desired_capacity = number # The number of Amazon EC2 instances that should be running in the autoscaling group
    })
    launch_template = object({
      image_id          = string # Amazon Linux 2023 AMI. The AMI from which to launch the instance
      instance_type     = string # The type of the instance. If present then `instance_requirements` cannot be present
      enable_monitoring = bool   # Enables/disables detailed monitoring
    })
  })
}