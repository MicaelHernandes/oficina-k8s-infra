variable "project" {
  description = "Prefixo do projeto."
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS (usado nas tags de subnet)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
}

variable "azs" {
  description = "Availability Zones."
  type        = list(string)
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
}

variable "region" {
  description = "Região AWS (usada no service_name do VPC endpoint)."
  type        = string
}

variable "enable_logs_vpc_endpoint" {
  description = "Cria o VPC endpoint de interface do CloudWatch Logs nas subnets privadas, para a Lambda de auth (repo 1) conseguir logar sem NAT. Desligado por padrão (custo)."
  type        = bool
  default     = false
}
