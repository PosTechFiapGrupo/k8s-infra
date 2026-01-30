variable "enable_github_actions_oidc" {
  description = "Habilita criação do OIDC Provider + IAM Role/Policy para GitHub Actions"
  type        = bool
  default     = true
}

variable "github_owner" {
  description = "Owner/org do repositório GitHub autorizado"
  type        = string
  default     = "postechfiapgrupo"
}

variable "github_repo" {
  description = "Nome do repositório GitHub autorizado"
  type        = string
  default     = "tech-challenge"
}

variable "github_ref" {
  description = "Ref permitida para assumir a role (ex: refs/heads/main)"
  type        = string
  default     = "refs/heads/main"
}

variable "github_actions_role_name" {
  description = "Nome da IAM Role assumida pelo GitHub Actions"
  type        = string
  default     = "GitHubActions-EKS-Deploy"
}

variable "github_actions_policy_name" {
  description = "Nome da IAM Policy anexada à role do GitHub Actions"
  type        = string
  default     = "GitHubActions-EKS-Deploy"
}

variable "github_actions_policy_is_permissive" {
  description = "Se true, usa eks:* (mais permissivo, ok para Fase 3). Se false, usa só eks:DescribeCluster."
  type        = bool
  default     = false
}
