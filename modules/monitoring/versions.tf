terraform {
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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
