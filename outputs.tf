# ---------------------------------------------------------------------------
# Outputs do repo. Também gravados no SSM Parameter Store (/oficina/...) para
# consumo desacoplado pelos repos 3 (RDS), 1 (Lambda) e 4 (app).
# ---------------------------------------------------------------------------

output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster EKS."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "ID da VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas (usadas pelo RDS e pela Lambda)."
  value       = module.vpc.private_subnet_ids
}

output "node_security_group_id" {
  description = "SG dos nós EKS (origem permitida no SG do RDS/Lambda)."
  value       = module.eks.node_security_group_id
}

output "ecr_repository_url" {
  description = "URL do repositório ECR da aplicação."
  value       = module.ecr.repository_url
}

output "certificate_arn" {
  description = "ARN do certificado ACM (api/app/grafana)."
  value       = module.dns_tls.certificate_arn
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider do EKS (IRSA)."
  value       = module.eks.oidc_provider_arn
}

output "github_role_arns" {
  description = "Mapa repo -> ARN da role OIDC assumida pela pipeline daquele repo."
  value       = module.github_oidc.github_role_arns
}

# ---------------------------------------------------------------------------
# SSM Parameter Store — espelha os outputs para consumo pelos demais repos.
# ---------------------------------------------------------------------------
resource "aws_ssm_parameter" "cluster_name" {
  name  = "/oficina/eks/cluster_name"
  type  = "String"
  value = module.eks.cluster_name
  tags  = local.tags
}

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/oficina/network/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
  tags  = local.tags
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/oficina/network/private_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.private_subnet_ids)
  tags  = local.tags
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/oficina/network/public_subnet_ids"
  type  = "StringList"
  value = join(",", module.vpc.public_subnet_ids)
  tags  = local.tags
}

resource "aws_ssm_parameter" "node_security_group_id" {
  name  = "/oficina/eks/node_security_group_id"
  type  = "String"
  value = module.eks.node_security_group_id
  tags  = local.tags
}

resource "aws_ssm_parameter" "ecr_repository_url" {
  name  = "/oficina/ecr/repository_url"
  type  = "String"
  value = module.ecr.repository_url
  tags  = local.tags
}

resource "aws_ssm_parameter" "certificate_arn" {
  name  = "/oficina/acm/certificate_arn"
  type  = "String"
  value = module.dns_tls.certificate_arn
  tags  = local.tags
}
