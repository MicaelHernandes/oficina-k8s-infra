# ---------------------------------------------------------------------------
# VPC — 2 AZs, subnets públicas + privadas, SEM NAT Gateway.
#
# Os nós do EKS ficam nas subnets PÚBLICAS (SG restritivo) para evitar o custo
# do NAT Gateway (~US$32/mês). As subnets privadas hospedam RDS (repo 3) e
# Lambda (repo 1), sem saída para a internet.
#
# Tags de subnet são obrigatórias para o AWS Load Balancer Controller
# descobrir onde criar ALBs (elb) e NLBs internos (internal-elb).
# ---------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = [for i, _ in var.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnets = [for i, _ in var.azs : cidrsubnet(var.vpc_cidr, 8, i + 10)]

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Nós em subnet pública precisam de IP público para registrar no cluster
  # (sem NAT). O ALB Controller também exige a tag kubernetes.io/role/elb.
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = var.tags
}
