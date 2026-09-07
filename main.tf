# ---------------------------------------------------------------------------
# Composição da infraestrutura base (repo 2).
#
# Ordem lógica de dependência:
#   vpc -> eks -> alb_controller -> monitoring
#   ecr / dns_tls / github_oidc são independentes do cluster.
# ---------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# Zona DNS gerenciada na Cloudflare — usada por dns_tls (validação ACM) e
# monitoring (CNAME do Grafana).
data "cloudflare_zone" "this" {
  name = var.domain
}

# --- Rede -------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project      = var.project
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs
  tags         = local.tags
}

# --- Cluster EKS ------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids

  node_instance_type = var.node_instance_type
  node_min_size      = var.node_min_size
  node_desired_size  = var.node_desired_size
  node_max_size      = var.node_max_size

  # Role de deploy do repo da aplicação recebe acesso admin ao cluster para
  # rodar `kubectl apply` na pipeline.
  deploy_role_arn = module.github_oidc.github_role_arns["oficina-api"]

  tags = local.tags
}

# --- Registry de imagens ----------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  tags            = local.tags
}

# --- OIDC GitHub -> AWS -----------------------------------------------------
module "github_oidc" {
  source = "./modules/github-oidc"

  project      = var.project
  account_id   = data.aws_caller_identity.current.account_id
  github_owner = var.github_owner
  repos        = local.github_repos
  tags         = local.tags
}

# --- AWS Load Balancer Controller + metrics-server --------------------------
module "alb_controller" {
  source = "./modules/alb-controller"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id
  region            = var.region
  tags              = local.tags
}

# --- Certificado ACM + registros DNS de validação ---------------------------
module "dns_tls" {
  source = "./modules/dns-tls"

  domain           = var.domain
  cloudflare_zone  = data.cloudflare_zone.this.id
  certificate_sans = [local.app_host, local.grafana_host]
  # domain_name principal do cert é o api_host (entrada pública da API).
  primary_domain = local.api_host
  tags           = local.tags
}

# --- Observabilidade (Prometheus + Grafana + Loki) --------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project         = var.project
  cluster_name    = module.eks.cluster_name
  grafana_host    = local.grafana_host
  certificate_arn = module.dns_tls.certificate_arn
  ingress_group   = local.ingress_group
  cloudflare_zone = data.cloudflare_zone.this.id
  tags            = local.tags

  # Garante que o ALB Controller esteja pronto antes de criar o Ingress.
  depends_on = [module.alb_controller]
}
