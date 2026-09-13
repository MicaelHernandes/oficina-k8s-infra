variable "region" {
  description = "Região AWS onde toda a infraestrutura é provisionada."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Prefixo/identificador do projeto, usado em nomes e tags."
  type        = string
  default     = "oficina"
}

variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
  default     = "oficina"
}

variable "cluster_version" {
  description = "Versão do Kubernetes do cluster EKS."
  type        = string
  default     = "1.31"
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones usadas (2 AZs para HA de subnets)."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "node_instance_type" {
  description = "Tipo de instância do managed node group. A conta está no Free plan da AWS, que só lança tipos free-tier-eligible (t3.medium é recusado)."
  type        = string
  default     = "m7i-flex.large"
}

variable "node_min_size" {
  description = "Mínimo de nós no node group."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Quantidade desejada de nós no node group."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Máximo de nós no node group (teto do autoscaling do HPA por pressão de pods)."
  type        = number
  default     = 3
}

variable "domain" {
  description = "Domínio raiz gerenciado na Cloudflare."
  type        = string
  default     = "codefive.com.br"
}

variable "cloudflare_api_token" {
  description = "Token de API da Cloudflare (secret CLOUDFLARE_API_TOKEN). Nunca commitar."
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "Owner/organização dos repositórios no GitHub."
  type        = string
  default     = "MicaelHernandes"
}

variable "ecr_repository_name" {
  description = "Nome do repositório ECR para a imagem da aplicação (repo oficina-api)."
  type        = string
  default     = "oficina-api"
}

variable "enable_logs_vpc_endpoint" {
  description = "Cria o VPC endpoint de interface do CloudWatch Logs nas subnets privadas (~US$7/mês por AZ). Desligado por padrão. Não é necessário para as Lambdas: o próprio serviço Lambda envia os logs delas ao CloudWatch, mesmo em subnet sem NAT. Só serve a cargas nas subnets privadas que chamem a API do CloudWatch Logs diretamente."
  type        = bool
  default     = false
}

variable "node_capacity_type" {
  description = "Modelo de compra do node group: SPOT (padrão, ~70% mais barato) ou ON_DEMAND."
  type        = string
  default     = "SPOT"
}
