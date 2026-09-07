output "vpc_id" {
  description = "ID da VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas."
  value       = module.vpc.private_subnets
}
