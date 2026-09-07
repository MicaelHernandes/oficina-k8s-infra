variable "project" {
  description = "Prefixo do projeto."
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "grafana_host" {
  description = "Host do Grafana (grafana.<domain>)."
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado ACM."
  type        = string
}

variable "ingress_group" {
  description = "Nome do IngressGroup (ALB compartilhado)."
  type        = string
}

variable "cloudflare_zone" {
  description = "Zone ID da Cloudflare."
  type        = string
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
}
