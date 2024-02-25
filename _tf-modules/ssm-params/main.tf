data "sops_file" "source" {
  source_file = var.sops_source_file
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_ssm_parameter" "sops" {
  for_each = nonsensitive(data.sops_file.source.data)

  name  = "${var.params_prefix}/${each.key}"
  value = data.sops_file.source.data[each.key]
  type  = "SecureString"

  tags = var.tags
}

locals {
  params_created = flatten([
    for key in nonsensitive(keys(data.sops_file.source.data)) : [
      {
        name      = key
        valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.params_prefix}/${key}"
      }
    ]
  ])
}