module "web_app_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  #aliases = ["chapter-web.com"]
  comment             = "Chapter Cloudfront ${title(var.env_name)} environement"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true

  origin = {
    frontend_web_app_s3 = {
      domain_name           = module.web_app_s3.s3_bucket_bucket_regional_domain_name
      origin_access_control = "frontend_web_app_s3"
    }
  }

  create_origin_access_control = true
  origin_access_control = {
    frontend_web_app_s3 = {
      description      = "CloudFront access to Chapter  ${title(var.env_name)} frontend app S3 bucket"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  default_cache_behavior = {
    target_origin_id           = "frontend_web_app_s3"
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # Managed-AllViewerExceptHostHeader
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy
    viewer_protocol_policy     = "https-only"

    allowed_methods      = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
    cached_methods       = ["GET", "HEAD"]
    compress             = true
    query_string         = true
    use_forwarded_values = false
  }

  logging_config = {
    bucket = module.logging_bucket.s3_bucket_bucket_domain_name
  }

  tags = local.common_tags
}