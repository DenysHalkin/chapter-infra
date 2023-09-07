include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/ecr/aws?version=1.6.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env_name

  common_tags = {
    Tier        = "application"
    Environment = local.env_name
  }

}

inputs = {
  repository_name = "${include.root.locals.project}-${local.env_name}-api"

  create_lifecycle_policy     = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 2 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 2
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = local.common_tags
}