output "github_role_arns" {
  description = "Mapa repo -> ARN da role OIDC."
  value       = { for k, r in aws_iam_role.repo : k => r.arn }
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider do GitHub Actions."
  value       = aws_iam_openid_connect_provider.github.arn
}
