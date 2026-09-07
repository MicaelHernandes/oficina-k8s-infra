# ---------------------------------------------------------------------------
# OIDC federado GitHub Actions -> AWS.
#
# Um OIDC provider + uma IAM role por repositório, com trust restrito ao repo
# e à branch master. Cada role recebe permissões pragmáticas ao seu escopo.
#
# Este módulo é o ÚNICO alvo do bootstrap local:
#   terraform apply -target=module.github_oidc
# executado uma vez pelo autor (usuário terraform-admin-new). Depois os ARNs
# viram o secret AWS_ROLE_ARN em cada repo.
# ---------------------------------------------------------------------------

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  tags            = var.tags
}

# Documento de trust por repo (branch master).
data "aws_iam_policy_document" "trust" {
  for_each = toset(var.repos)

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${each.key}:ref:refs/heads/master"]
    }
  }
}

resource "aws_iam_role" "repo" {
  for_each = toset(var.repos)

  name               = "${var.project}-gha-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.trust[each.key].json
  tags               = var.tags
}

# Permissões pragmáticas por repo (escopo de serviços que cada pipeline usa).
locals {
  repo_policies = {
    "oficina-k8s-infra" = {
      actions = [
        "ec2:*", "eks:*", "ecr:*", "elasticloadbalancing:*",
        "iam:*", "acm:*", "ssm:*", "autoscaling:*", "kms:*",
        "secretsmanager:*", "logs:*", "cloudwatch:*", "sts:*"
      ]
    }
    "oficina-db-infra" = {
      actions = [
        "rds:*", "ec2:Describe*", "ec2:*SecurityGroup*", "ec2:*Subnet*",
        "secretsmanager:*", "ssm:*", "kms:*", "iam:PassRole",
        "iam:CreateServiceLinkedRole", "logs:*", "sts:*"
      ]
    }
    "oficina-auth-lambda" = {
      actions = [
        "lambda:*", "apigateway:*", "ec2:Describe*", "ec2:*NetworkInterface*",
        "ec2:*SecurityGroup*", "iam:*", "secretsmanager:*", "ssm:*",
        "logs:*", "sts:*"
      ]
    }
    "oficina-api" = {
      actions = [
        "ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage",
        "ecr:PutImage", "ecr:InitiateLayerUpload", "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload", "eks:DescribeCluster", "eks:ListClusters",
        "ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath",
        "secretsmanager:GetSecretValue", "sts:GetCallerIdentity"
      ]
    }
  }
}

data "aws_iam_policy_document" "repo" {
  for_each = local.repo_policies

  statement {
    effect    = "Allow"
    actions   = each.value.actions
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "repo" {
  for_each = local.repo_policies

  name   = "${var.project}-gha-${each.key}-policy"
  role   = aws_iam_role.repo[each.key].id
  policy = data.aws_iam_policy_document.repo[each.key].json
}
