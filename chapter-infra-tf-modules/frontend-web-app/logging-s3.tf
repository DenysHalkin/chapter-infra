data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

module "logging_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "${var.project}-${var.env_name}-cloudfront-logging-${var.region_alias}"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  grant = [
    {
      type       = "CanonicalUser"
      permission = "FULL_CONTROL"
      id         = data.aws_canonical_user_id.current.id
    },
    {
      type       = "CanonicalUser"
      permission = "FULL_CONTROL"
      id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
    }
  ]

  owner = {
    id = data.aws_canonical_user_id.current.id
  }

  attach_deny_insecure_transport_policy  = true
  attach_require_latest_tls_policy       = true
  attach_deny_unencrypted_object_uploads = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "logs_rotation"
      enabled = true

      filter = {
        prefix = ""
      }

      expiration = {
        days = 1
      }
    }
  ]

  versioning = {
    status     = true
    mfa_delete = false
  }

  tags = var.common_tags
}