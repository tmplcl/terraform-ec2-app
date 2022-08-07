data "aws_route53_zone" "app" {
  name         = var.hosted_zone
  private_zone = false
}

resource "aws_acm_certificate" "app" {
  domain_name               = local.route
  subject_alternative_names = ["www.${local.route}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_route53_record" "app" {
  allow_overwrite = true
  name            = local.route
  type            = "A"
  zone_id         = data.aws_route53_zone.app.zone_id

  alias {
    name                   = aws_alb.app.dns_name
    zone_id                = aws_alb.app.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_acm_certificate.app]
}

//noinspection HILUnresolvedReference
resource "aws_route53_record" "app_cert_validations" {
  for_each = {
  for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
  }
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.app.zone_id
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60

  depends_on = [aws_acm_certificate.app]
}

resource "aws_acm_certificate_validation" "app_cert_validation" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.app_cert_validations : record.fqdn]
}
