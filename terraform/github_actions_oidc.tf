locals {
  github_sub = "repo:${var.github_owner}/${var.github_repo}:ref:${var.github_ref}"

  github_actions_policy_actions = var.github_actions_policy_is_permissive ? ["eks:*"] : ["eks:DescribeCluster"]
}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enable_github_actions_oidc ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions_eks_deploy" {
  count = var.enable_github_actions_oidc ? 1 : 0

  name = var.github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions[0].arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.github_sub
          }
        }
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = var.github_actions_role_name
    Purpose     = "github-actions-oidc-eks-deploy"
    Environment = var.environment
    Project     = var.project_name
  })
}

resource "aws_iam_policy" "github_actions_eks_deploy" {
  count = var.enable_github_actions_oidc ? 1 : 0

  name = var.github_actions_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = local.github_actions_policy_actions
        Resource = "*"
      }
    ]
  })

  tags = merge(var.additional_tags, {
    Name        = var.github_actions_policy_name
    Purpose     = "github-actions-oidc-eks-deploy"
    Environment = var.environment
    Project     = var.project_name
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  count = var.enable_github_actions_oidc ? 1 : 0

  role       = aws_iam_role.github_actions_eks_deploy[0].name
  policy_arn = aws_iam_policy.github_actions_eks_deploy[0].arn
}

output "github_actions_oidc_provider_arn" {
  description = "ARN do OIDC provider do GitHub Actions"
  value       = var.enable_github_actions_oidc ? aws_iam_openid_connect_provider.github_actions[0].arn : null
}

output "github_actions_role_arn" {
  description = "ARN da role para configurar no GitHub Secret AWS_ROLE_ARN"
  value       = var.enable_github_actions_oidc ? aws_iam_role.github_actions_eks_deploy[0].arn : null
}

output "github_actions_sub_condition" {
  description = "String exata usada na condição token.actions.githubusercontent.com:sub"
  value       = local.github_sub
}
