# =============================================================================
# Terraform Outputs - Infraestrutura Principal
# =============================================================================

# =============================================================================
# VPC Outputs
# =============================================================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = module.vpc.vpc_cidr
}

output "vpc_arn" {
  description = "ARN da VPC"
  value       = module.vpc.vpc_arn
}

# =============================================================================
# Subnet Outputs
# =============================================================================

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "private_subnet_cidrs" {
  description = "CIDR blocks das subnets privadas"
  value       = module.vpc.private_subnet_cidrs
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "public_subnet_cidrs" {
  description = "CIDR blocks das subnets públicas"
  value       = module.vpc.public_subnet_cidrs
}

# =============================================================================
# Security Group Outputs
# =============================================================================

output "eks_security_group_id" {
  description = "ID do Security Group do EKS Cluster"
  value       = module.security_groups.eks_cluster_sg_id
}

output "eks_nodes_security_group_id" {
  description = "ID do Security Group dos EKS Worker Nodes"
  value       = module.security_groups.eks_nodes_sg_id
}

output "rds_allowed_sg_id" {
  description = "ID do Security Group permitido para RDS MySQL"
  value       = module.security_groups.rds_mysql_sg_id
}

output "lambda_security_group_id" {
  description = "ID do Security Group para Lambda"
  value       = module.security_groups.lambda_sg_id
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = module.security_groups.alb_sg_id
}

# =============================================================================
# EKS Outputs
# =============================================================================

output "eks_cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Versão do Kubernetes no cluster"
  value       = module.eks.cluster_version
}

output "eks_cluster_arn" {
  description = "ARN do cluster EKS"
  value       = module.eks.cluster_arn
}

output "eks_cluster_certificate_authority_data" {
  description = "Certificate Authority data do cluster EKS"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "ID do Security Group criado pelo EKS"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_arn" {
  description = "ARN do Node Group"
  value       = module.eks.node_group_arn
}

output "eks_oidc_provider_arn" {
  description = "ARN do OIDC Provider para IRSA"
  value       = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  description = "URL do OIDC Provider"
  value       = module.eks.oidc_provider_url
}

# =============================================================================
# IAM Outputs
# =============================================================================

output "eks_cluster_role_arn" {
  description = "ARN da IAM Role do cluster EKS"
  value       = module.eks.cluster_iam_role_arn
}

output "eks_node_role_arn" {
  description = "ARN da IAM Role dos worker nodes"
  value       = module.eks.node_iam_role_arn
}

output "irsa_base_role_arn" {
  description = "ARN da IAM Role base para IRSA"
  value       = module.eks.irsa_base_role_arn
}

output "secrets_manager_role_arn" {
  description = "ARN da IAM Role para acesso ao Secrets Manager"
  value       = module.eks.secrets_manager_role_arn
}

# =============================================================================
# Networking Outputs
# =============================================================================

output "nat_gateway_public_ips" {
  description = "IPs públicos dos NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

# =============================================================================
# Comandos Úteis
# =============================================================================

output "kubeconfig_command" {
  description = "Comando para configurar o kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "kubectl_config_context" {
  description = "Contexto do kubectl para este cluster"
  value       = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${module.eks.cluster_name}"
}

# =============================================================================
# Resumo da Infraestrutura
# =============================================================================

output "infrastructure_summary" {
  description = "Resumo completo da infraestrutura provisionada"
  value = {
    project     = var.project_name
    environment = var.environment
    region      = var.aws_region

    vpc = {
      id   = module.vpc.vpc_id
      cidr = module.vpc.vpc_cidr
    }

    subnets = {
      private = module.vpc.private_subnet_ids
      public  = module.vpc.public_subnet_ids
    }

    security_groups = {
      eks_cluster = module.security_groups.eks_cluster_sg_id
      eks_nodes   = module.security_groups.eks_nodes_sg_id
      rds_mysql   = module.security_groups.rds_mysql_sg_id
      lambda      = module.security_groups.lambda_sg_id
      alb         = module.security_groups.alb_sg_id
    }

    eks = {
      cluster_name = module.eks.cluster_name
      endpoint     = module.eks.cluster_endpoint
      version      = module.eks.cluster_version
      oidc_arn     = module.eks.oidc_provider_arn
    }
  }
}
