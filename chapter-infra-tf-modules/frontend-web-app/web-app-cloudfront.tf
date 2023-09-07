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
    target_origin_id       = "frontend_web_app_s3"
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" #todo
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods      = ["GET", "HEAD", "OPTIONS"]
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