# ---------------------------------------------------------------------------
# Versões e backend de estado.
#
# O apply roda exclusivamente no GitHub Actions (branch master). O estado fica
# no S3 com lock no DynamoDB, ambos provisionados no bootstrap manual.
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.40"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket         = "oficina-tfstate-909314263457"
    key            = "oficina-k8s-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "oficina-tflock"
    encrypt        = true
  }
}
