locals {
  custom_domain = "test.com"
}

resource "aws_apprunner_custom_domain_association" "runner_custom_domain" {
  domain_name = local.custom_domain
  service_arn = aws_apprunner_service.runner_service.arn
}

resource "aws_route53_record" "runner_custom_domain_record" {
  allow_overwrite = true
  name            = local.custom_domain
  records         = [
    aws_apprunner_custom_domain_association.runner_custom_domain.dns_target
  ]
  ttl             = 60
  type            = "CNAME"
  zone_id         = aws_route53_zone.hosted_zone.zone_id
}

resource "aws_route53_record" "runner_custom_domain_validation_record" {
  for_each        = {for r in aws_apprunner_custom_domain_association.runner_custom_domain.certificate_validation_records :  r.name => r}
  allow_overwrite = true
  name            = each.value.name
  records         = [
    each.value.value
  ]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hosted_zone.zone_id
}