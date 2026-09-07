## O que muda

<!-- Descreva objetivamente a alteração de infraestrutura. -->

## Tipo

- [ ] Rede (VPC/subnets/SG)
- [ ] Cluster EKS / node group
- [ ] ECR
- [ ] ALB Controller / Ingress
- [ ] DNS / TLS (ACM / Cloudflare)
- [ ] Observabilidade (Prometheus/Grafana/Loki)
- [ ] OIDC / IAM

## Checklist

- [ ] `terraform fmt -recursive` aplicado
- [ ] `terraform validate` passou localmente
- [ ] Revisei o `terraform plan` comentado pelo CI
- [ ] Não há segredos commitados (token Cloudflare, chaves AWS)
- [ ] PR direcionado a `homolog` (ou de `homolog` para `master`)

## Impacto de custo

<!-- Este apply cria/destrói recursos pagos? EKS, ALB, etc. -->
