output "grafana_url" {
  description = "URL pública do Grafana."
  value       = "https://${var.grafana_host}"
}

output "alb_hostname" {
  description = "Hostname do ALB compartilhado (descoberto via Ingress do Grafana)."
  value       = kubernetes_ingress_v1.grafana.status[0].load_balancer[0].ingress[0].hostname
}

output "grafana_admin_secret_arn" {
  description = "ARN do secret com as credenciais admin do Grafana."
  value       = aws_secretsmanager_secret.grafana_admin.arn
}
