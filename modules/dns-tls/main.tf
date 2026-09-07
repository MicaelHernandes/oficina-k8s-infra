# ---------------------------------------------------------------------------
# Certificado ACM (TLS) para api/app/grafana, validado por DNS na Cloudflare.
#
# O domain_name principal é api.codefive.com.br; app e grafana entram como SAN.
# Os CNAMEs finais dos subdomínios são criados junto dos Ingress (grafana neste
# repo, app no repo 4). Aqui só emitimos e validamos o certificado.
# ---------------------------------------------------------------------------
resource "aws_acm_certificate" "this" {
  domain_name               = var.primary_domain
  subject_alternative_names = var.certificate_sans
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Registros CNAME de validação do ACM na Cloudflare.
resource "cloudflare_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone
  name    = each.value.name
  value   = each.value.value
  type    = each.value.type
  ttl     = 60
  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in cloudflare_record.validation : r.hostname]
}
