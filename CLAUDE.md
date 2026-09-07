# Convenções — oficina-k8s-infra

Repositório 2 de 4 do Tech Challenge Fase 3. Provisiona a base AWS: VPC, EKS,
ECR, ALB Controller, DNS/TLS (ACM + Cloudflare), observabilidade e roles OIDC.

## Regras

- **`terraform apply` roda SÓ no GitHub Actions** (branch `master`, `deploy.yml`).
  Exceção única: bootstrap do OIDC, uma vez, na máquina do autor:
  `terraform apply -target=module.github_oidc`.
- Localmente só se roda `init`, `fmt`, `validate`, `plan`.
- Branch principal protegida; merge só via PR (`feature/*` → `homolog` → `master`).
- Segredos nunca no repo: token Cloudflare via secret `CLOUDFLARE_API_TOKEN`
  (`TF_VAR_cloudflare_api_token`); credenciais AWS via OIDC (`AWS_ROLE_ARN`).
- Backend S3 `oficina-tfstate-909314263457`, lock DynamoDB `oficina-tflock`.
- Região `us-east-1`. Tudo com as tags de `locals.tf`.

## Estrutura

- Arquivos raiz orquestram os módulos em `modules/`.
- Cada módulo tem `main.tf`, `variables.tf`, `outputs.tf` e, quando usa
  helm/kubernetes/cloudflare/tls, um `versions.tf` declarando os providers.
- Outputs também vão para o SSM (`/oficina/...`) para os repos 1, 3 e 4.

## Ordem de provisionamento global

2 (este) → 3 (RDS) → 1 (Lambda) → 4 (app).
