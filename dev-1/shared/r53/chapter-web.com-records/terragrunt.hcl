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
      records = ["ns-2033.awsdns-62.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
    },
    {
      name = ""
      type = "NS"
      ttl  = 172800
      records = [
        "ns-1423.awsdns-49.org.",
        "ns-2033.awsdns-62.co.uk.",
        "ns-243.awsdns-30.com.",
        "ns-920.awsdns-51.net."
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