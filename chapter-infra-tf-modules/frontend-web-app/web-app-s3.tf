locals {
  web_app_s3_name = "${var.project}-${var.env_name}-frontend-web-app-${var.region_alias}"
}

module "web_app_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = local.web_app_s3_name

  attach_deny_insecure_transport_policy  = true
  attach_require_latest_tls_policy       = true
  attach_deny_unencrypted_object_uploads = true
  attach_policy                          = true
  policy                                 = data.aws_iam_policy_document.web_app_s3_policy.json

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "keep_only_1_version_of_files"
      enabled = true

      filter = {
        prefix = ""
      }

      noncurrent_version_expiration = {
        newer_noncurrent_versions = 1
        days                      = 1
      }
    }
  ]

  versioning = {
    status     = true
    mfa_delete = false
  }

  tags = local.common_tags
}

data "aws_iam_policy_document" "web_app_s3_policy" {
  # Origin Access Controls
  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.web_app_s3_name}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.web_app_cloudfront.cloudfront_distribution_arn]
    }
  }
}