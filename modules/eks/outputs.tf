output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA do cluster (base64) para autenticação dos providers."
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider do cluster (IRSA)."
  value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
  description = "SG dos nós EKS."
  value       = module.eks.node_security_group_id
}
