variable "domain" {
  description = "Domínio raiz."
  type        = string
}

variable "primary_domain" {
  description = "Domain name principal do certificado (api.<domain>)."
  type        = string
}

variable "certificate_sans" {
  description = "Subject Alternative Names do certificado (app, grafana)."
  type        = list(string)
}

variable "cloudflare_zone" {
  description = "Zone ID da Cloudflare."
  type        = string
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
}
