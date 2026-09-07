variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN do OIDC provider do cluster (IRSA)."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "region" {
  description = "Região AWS."
  type        = string
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
}
