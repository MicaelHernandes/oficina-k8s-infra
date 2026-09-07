# ---------------------------------------------------------------------------
# Cluster EKS gerenciado.
#
# - 1 managed node group t3.medium (min 1, desired 2, max 3). O HPA (repo 4)
#   escala pods; a pressão de pods pode disparar novos nós até o max.
# - Nós nas subnets PÚBLICAS (sem NAT), com IP público para registrar no
#   control plane e puxar imagens do ECR.
# - Add-ons essenciais + EBS CSI (política anexada à role dos nós).
# - Access entry dando admin do cluster à role de deploy do repo da app,
#   para a pipeline rodar `kubectl apply`.
# ---------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.public_subnets
  control_plane_subnet_ids = var.private_subnets

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver     = {}
    eks-pod-identity-agent = {}
  }

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = var.node_min_size
      desired_size   = var.node_desired_size
      max_size       = var.node_max_size
      subnet_ids     = var.public_subnets

      # Nós em subnet pública precisam de IP público (sem NAT).
      # Política do EBS CSI anexada aos nós evita IRSA separado.
      iam_role_additional_policies = {
        ebs_csi = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        ssm     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  # Concede admin do cluster à pipeline de deploy do repo oficina-api.
  access_entries = {
    deploy = {
      principal_arn = var.deploy_role_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = var.tags
}

# Libera o tráfego dos nós entre si e a comunicação com o control plane já é
# tratada pelo módulo. Aqui garantimos que a subnet pública associe IP público
# via node group (map_public_ip_on_launch já vem da VPC).
