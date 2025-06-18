 module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  

  domain_name = var.domain_name
  zone_id     = var.zone_id
  create_route53_records  = false
  validation_method       = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]

}
 

resource "cloudflare_dns_record" "validation_record" {
  zone_id = var.zone_id
  ttl     = "1"
  name    = module.acm.acm_certificate_domain_validation_options[0].resource_record_name
  type    = module.acm.acm_certificate_domain_validation_options[0].resource_record_type
  content = module.acm.acm_certificate_domain_validation_options[0].resource_record_value
}
