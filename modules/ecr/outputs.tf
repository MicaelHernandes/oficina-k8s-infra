output "repository_url" {
  description = "URL do repositório ECR."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN do repositório ECR."
  value       = aws_ecr_repository.this.arn
}
