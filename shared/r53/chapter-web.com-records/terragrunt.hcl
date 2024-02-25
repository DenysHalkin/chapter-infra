include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source  = "tfr://registry.terraform.io/terraform-aws-modules/route53/aws//modules/records?version=2.10.2"
}

dependencies {
  paths = ["../chapter-web.com-zones"]
}

dependency "r53_zone" {
  config_path = "${get_terragrunt_dir()}/../chapter-web.com-zones"
}

locals {
  common_tags = {
    Environment = "shared"
  }
}

inputs = {
  zone_id = dependency.r53_zone.outputs.route53_zone_zone_id["chapter-web.com"]

  records = [
    {
      name = ""
      type = "SOA"
      ttl  = 900
      records = ["ns-1733.awsdns-24.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]

    },
    {
      name = ""
      type = "NS"
      ttl  = 172800
      records = [
        "ns-1357.awsdns-41.org.",
        "ns-1733.awsdns-24.co.uk.",
        "ns-206.awsdns-25.com.",
        "ns-725.awsdns-26.net.",

      ]
    },
    {
      name = ""
      type = "TXT"
      ttl  = 86400
      records = ["v=spf1 include:amazonses.com ~all"]
    }
  ]
}

#terragrunt import 'aws_route53_record.this[" SOA"]' Z08570161J14CBNI3TX8K_chapter-web.com_SOA
#terragrunt import 'aws_route53_record.this[" NS"]' Z08570161J14CBNI3TX8K_chapter-web.com_NS