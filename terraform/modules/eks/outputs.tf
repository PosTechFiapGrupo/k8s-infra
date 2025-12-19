# =============================================================================
# Módulo EKS - Outputs
# =============================================================================

output "cluster_id" {
  description = "ID do cluster EKS"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "ARN do cluster EKS"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Versão do Kubernetes do cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Certificate Authority data do cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "ID do Security Group criado pelo EKS"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "ARN da IAM Role do cluster"
  value       = aws_iam_role.eks_cluster.arn
}

output "cluster_iam_role_name" {
  description = "Nome da IAM Role do cluster"
  value       = aws_iam_role.eks_cluster.name
}

output "node_group_id" {
  description = "ID do Node Group"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "ARN do Node Group"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status do Node Group"
  value       = aws_eks_node_group.main.status
}

output "node_iam_role_arn" {
  description = "ARN da IAM Role dos worker nodes"
  value       = aws_iam_role.eks_nodes.arn
}

output "node_iam_role_name" {
  description = "Nome da IAM Role dos worker nodes"
  value       = aws_iam_role.eks_nodes.name
}

output "oidc_provider_arn" {
  description = "ARN do OIDC Provider para IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL do OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

output "irsa_base_role_arn" {
  description = "ARN da IAM Role base para IRSA"
  value       = aws_iam_role.irsa_base.arn
}

output "secrets_manager_role_arn" {
  description = "ARN da IAM Role para Secrets Manager"
  value       = aws_iam_role.secrets_manager.arn
}

# Output para configurar kubectl
output "kubeconfig_command" {
  description = "Comando para configurar o kubeconfig"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${data.aws_caller_identity.current.account_id}"
}

# Cluster info consolidado
output "cluster_info" {
  description = "Informações consolidadas do cluster"
  value = {
    name              = aws_eks_cluster.main.name
    endpoint          = aws_eks_cluster.main.endpoint
    version           = aws_eks_cluster.main.version
    arn               = aws_eks_cluster.main.arn
    security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
    oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  }
}

# Data source para região
data "aws_caller_identity" "output" {}

output "oidc_issuer_url" {
  description = "OIDC issuer URL do EKS (host/path sem https://) para uso em IRSA"
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}
