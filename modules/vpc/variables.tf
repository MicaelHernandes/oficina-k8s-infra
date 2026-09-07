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
