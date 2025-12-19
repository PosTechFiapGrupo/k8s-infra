# =============================================================================
# Módulo Security Groups - Outputs
# =============================================================================

output "eks_cluster_sg_id" {
  description = "ID do Security Group do EKS Cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_cluster_sg_arn" {
  description = "ARN do Security Group do EKS Cluster"
  value       = aws_security_group.eks_cluster.arn
}

output "eks_nodes_sg_id" {
  description = "ID do Security Group dos EKS Worker Nodes"
  value       = aws_security_group.eks_nodes.id
}

output "eks_nodes_sg_arn" {
  description = "ARN do Security Group dos EKS Worker Nodes"
  value       = aws_security_group.eks_nodes.arn
}

output "rds_mysql_sg_id" {
  description = "ID do Security Group do RDS MySQL"
  value       = aws_security_group.rds_mysql.id
}

output "rds_mysql_sg_arn" {
  description = "ARN do Security Group do RDS MySQL"
  value       = aws_security_group.rds_mysql.arn
}

output "lambda_sg_id" {
  description = "ID do Security Group do Lambda"
  value       = aws_security_group.lambda.id
}

output "lambda_sg_arn" {
  description = "ARN do Security Group do Lambda"
  value       = aws_security_group.lambda.arn
}

output "alb_sg_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "alb_sg_arn" {
  description = "ARN do Security Group do ALB"
  value       = aws_security_group.alb.arn
}

# Output consolidado para referência
output "security_groups" {
  description = "Mapa de todos os Security Groups"
  value = {
    eks_cluster = {
      id  = aws_security_group.eks_cluster.id
      arn = aws_security_group.eks_cluster.arn
    }
    eks_nodes = {
      id  = aws_security_group.eks_nodes.id
      arn = aws_security_group.eks_nodes.arn
    }
    rds_mysql = {
      id  = aws_security_group.rds_mysql.id
      arn = aws_security_group.rds_mysql.arn
    }
    lambda = {
      id  = aws_security_group.lambda.id
      arn = aws_security_group.lambda.arn
    }
    alb = {
      id  = aws_security_group.alb.id
      arn = aws_security_group.alb.arn
    }
  }
}
