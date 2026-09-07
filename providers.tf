# ---------------------------------------------------------------------------
# Providers.
#
# - aws        : região us-east-1, tags padrão aplicadas a todos os recursos.
# - cloudflare : DNS da zona codefive.com.br (token via variável / secret).
# - kubernetes / helm : autenticam no cluster EKS recém-criado usando o token
#   gerado pelo `aws eks get-token` (exec plugin), evitando tokens expirados.
# ---------------------------------------------------------------------------
provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}
