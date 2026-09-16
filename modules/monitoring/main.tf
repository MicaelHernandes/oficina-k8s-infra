# ---------------------------------------------------------------------------
# Observabilidade: kube-prometheus-stack (Prometheus + Alertmanager + Grafana)
# + Loki/Promtail para logs. Grafana exposto por um Ingress ALB compartilhado
# (mesmo group.name do app), com TLS do ACM.
#
# - Descoberta de ServiceMonitor/PodMonitor/PrometheusRule liberada para todos
#   os namespaces (o repo 4 publica os seus).
# - Sidecar do Grafana carrega dashboards de ConfigMaps com label
#   grafana_dashboard=1 (dashboards de negócio vêm do repo 4).
# - Senha do admin do Grafana em Secrets Manager (/oficina/grafana/admin).
# - Armazenamento efêmero (emptyDir/filesystem) para minimizar custo; não é
#   durável — documentado como trade-off da apresentação.
# ---------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "random_password" "grafana_admin" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "grafana_admin" {
  name = "/oficina/grafana/admin"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "grafana_admin" {
  secret_id = aws_secretsmanager_secret.grafana_admin.id
  secret_string = jsonencode({
    user     = "admin"
    password = random_password.grafana_admin.result
  })
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "91.4.1"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [yamlencode({
    grafana = {
      adminPassword = random_password.grafana_admin.result
      service = {
        type = "ClusterIP"
      }
      ingress = {
        enabled = false # Ingress criado separadamente (ALB compartilhado).
      }
      sidecar = {
        dashboards = {
          enabled         = true
          label           = "grafana_dashboard"
          searchNamespace = "ALL"
        }
      }
      additionalDataSources = [
        {
          name   = "Loki"
          type   = "loki"
          url    = "http://loki.monitoring.svc.cluster.local:3100"
          access = "proxy"
        }
      ]
    }
    prometheus = {
      prometheusSpec = {
        serviceMonitorSelectorNilUsesHelmValues = false
        podMonitorSelectorNilUsesHelmValues     = false
        ruleSelectorNilUsesHelmValues           = false
        retention                               = "6h"
      }
    }
    alertmanager = {
      enabled = true
    }
    # EKS: o control plane é gerenciado pela AWS e roda fora do cluster.
    # Scheduler e controller-manager não expõem métricas, então os
    # ServiceMonitors do chart não acham alvo e as regras
    # absent(up{job="kube-scheduler"|"kube-controller-manager"} == 1)
    # disparam KubeSchedulerDown e KubeControllerManagerDown (critical) o
    # tempo todo, com os componentes saudáveis. Desliga scrape e regras deles.
    kubeScheduler = {
      enabled = false
    }
    kubeControllerManager = {
      enabled = false
    }
  })]

  depends_on = [kubernetes_namespace_v1.monitoring]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.10.3" # última versão; o chart foi descontinuado pela Grafana
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [yamlencode({
    loki = {
      persistence = { enabled = false }
    }
    promtail = {
      enabled = true
    }
  })]

  depends_on = [kubernetes_namespace_v1.monitoring]
}

# Ingress ALB do Grafana — group.name compartilhado com o app (um único ALB).
# wait_for_load_balancer expõe o hostname do ALB para criar o CNAME.
resource "kubernetes_ingress_v1" "grafana" {
  wait_for_load_balancer = true

  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/group.name"      = var.ingress_group
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80},{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.grafana_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kube-prometheus-stack-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.kube_prometheus_stack]
}

# CNAME grafana.<domain> -> hostname do ALB compartilhado.
resource "cloudflare_record" "grafana" {
  zone_id = var.cloudflare_zone
  name    = var.grafana_host
  value   = kubernetes_ingress_v1.grafana.status[0].load_balancer[0].ingress[0].hostname
  type    = "CNAME"
  ttl     = 300
  proxied = false
}
