variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "public_subnets" {
  description = "Subnets públicas (onde os nós rodam)."
  type        = list(string)
}

variable "private_subnets" {
  description = "Subnets privadas (control plane ENIs)."
  type        = list(string)
}

variable "node_instance_type" {
  description = "Tipo de instância dos nós."
  type        = string
}

variable "node_min_size" {
  description = "Mínimo de nós."
  type        = number
}

variable "node_desired_size" {
  description = "Nós desejados."
  type        = number
}

variable "node_max_size" {
  description = "Máximo de nós."
  type        = number
}

variable "deploy_role_arn" {
  description = "ARN da role OIDC do repo oficina-api (recebe admin do cluster)."
  type        = string
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
}

variable "node_capacity_type" {
  description = "Modelo de compra do node group: SPOT (~70% mais barato, pode ser interrompido) ou ON_DEMAND."
  type        = string
  default     = "SPOT"
}
