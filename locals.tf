locals {
  tags = {
    Project   = var.project
    ManagedBy = "terraform"
    Repo      = "oficina-k8s-infra"
  }

  # Subdomínios que este repo gerencia.
  app_host     = "app.${var.domain}"     # Ingress do backend (repo 4) via ALB compartilhado
  grafana_host = "grafana.${var.domain}" # Grafana via ALB compartilhado
  api_host     = "api.${var.domain}"     # API Gateway (repo 1); incluído no SAN do ACM

  # Nome do IngressGroup compartilhado — um único ALB serve app + grafana.
  ingress_group = "${var.project}-shared"

  # Microsserviços da Fase 4 (um repo cada). Cada um ganha repositório ECR,
  # role OIDC com permissões de deploy e acesso de admin ao cluster.
  # oficina-api é o OS Service (orquestrador da saga).
  app_services = [
    "oficina-api",
    "oficina-billing-service",
    "oficina-execution-service",
  ]

  # Repositórios que assumem roles OIDC criadas por este repo.
  github_repos = concat([
    "oficina-k8s-infra",
    "oficina-db-infra",
    "oficina-auth-lambda",
  ], local.app_services)
}
