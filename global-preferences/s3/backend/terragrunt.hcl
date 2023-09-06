include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/s3-bucket/aws?version=3.15.1"
}

inputs = {
  bucket = "chapter-terraform-state-usw2"

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

  versioning = {
    status     = true
    mfa_delete = false
  }

  tags = {
    Application = "global-preferences"
  }
}
