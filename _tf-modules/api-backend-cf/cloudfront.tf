data "aws_route53_zone" "this" {
  name = var.app_domain_name
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases         = ["${var.app_subdomain}.${var.app_domain_name}"]
  comment         = "Chapter Cloudfront ${title(var.env_name)} API Backend application"
  price_class     = "PriceClass_100"
  enabled         = true
  http_version    = "http2and3"
  is_ipv6_enabled = true

  create_origin_access_control = false

  origin = {
    api-backend = {
      domain_name = var.api_alb_domain_name

      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }

      custom_header = [
        {
          name  = "CF_ORIGIN_ACCESS_TOKEN"
          value = "Qa123456"
        }
      ]

      origin_shield = {
        enabled              = true
        origin_shield_region = "eu-central-1"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id         = "api-backend"
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Managed-AllViewer
    viewer_protocol_policy   = "https-only"

    allowed_methods      = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
    cached_methods       = ["GET", "HEAD"]
    use_forwarded_values = false
  }

  logging_config = {
    bucket          = module.logging_bucket.s3_bucket_bucket_domain_name
    include_cookies = false
    prefix          = "chapter-${var.env_name}-cloudfront-logs"
  }

  viewer_certificate = {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags

  depends_on = [
    module.logging_bucket.aws_s3_bucket_acl
  ]
}

module "r53_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.10.2"

  zone_id = data.aws_route53_zone.this.zone_id

  records = [
    {
      name = var.app_subdomain
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = var.app_subdomain
      type = "AAAA"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    }
  ]
}