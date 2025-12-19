# =============================================================================
# Módulo Security Groups - Main Configuration
# =============================================================================
# Este módulo cria os Security Groups para:
# - EKS Cluster (Control Plane)
# - EKS Worker Nodes
# - RDS MySQL (acesso apenas do EKS e Lambda)

locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Module = "security-groups"
    },
    var.additional_tags
  )
}

# =============================================================================
# Security Group - EKS Cluster (Control Plane)
# =============================================================================

resource "aws_security_group" "eks_cluster" {
  name        = "${local.name}-eks-cluster-sg"
  description = "Security group para o EKS Cluster Control Plane"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-eks-cluster-sg"
      Type = "eks-cluster"
    }
  )
}

# Regras de Ingress - EKS Cluster
resource "aws_security_group_rule" "eks_cluster_ingress_nodes" {
  description              = "Permite comunicacao dos worker nodes para o control plane"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
}

# Regras de Egress - EKS Cluster
resource "aws_security_group_rule" "eks_cluster_egress_nodes" {
  description              = "Permite comunicacao do control plane para os worker nodes"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "eks_cluster_egress_nodes_https" {
  description              = "Permite HTTPS do control plane para os worker nodes"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
}

# =============================================================================
# Security Group - EKS Worker Nodes
# =============================================================================

resource "aws_security_group" "eks_nodes" {
  name        = "${local.name}-eks-nodes-sg"
  description = "Security group para os EKS Worker Nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name                                      = "${local.name}-eks-nodes-sg"
      Type                                      = "eks-nodes"
      "kubernetes.io/cluster/${local.name}-eks" = "owned"
    }
  )
}

# Regras de Ingress - Worker Nodes
resource "aws_security_group_rule" "eks_nodes_ingress_self" {
  description              = "Permite comunicacao entre os worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "eks_nodes_ingress_cluster" {
  description              = "Permite comunicacao do control plane para os worker nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "eks_nodes_ingress_cluster_https" {
  description              = "Permite HTTPS do control plane para os worker nodes"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
}

# Regras de Egress - Worker Nodes
resource "aws_security_group_rule" "eks_nodes_egress_all" {
  description       = "Permite todo trafego de saida dos worker nodes"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

# =============================================================================
# Security Group - RDS MySQL
# =============================================================================

resource "aws_security_group" "rds_mysql" {
  name        = "${local.name}-rds-mysql-sg"
  description = "Security group para RDS MySQL - acesso apenas do EKS e Lambda"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-rds-mysql-sg"
      Type = "rds"
    }
  )
}

# Regra de Ingress - RDS - Acesso do EKS
resource "aws_security_group_rule" "rds_ingress_eks" {
  description              = "Permite acesso MySQL (3306) apenas do EKS"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.rds_mysql.id
}

# Regra de Ingress - RDS - Acesso do Lambda
resource "aws_security_group_rule" "rds_ingress_lambda" {
  description              = "Permite acesso MySQL (3306) do Lambda"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda.id
  security_group_id        = aws_security_group.rds_mysql.id
}

# Regra de Egress - RDS
resource "aws_security_group_rule" "rds_egress" {
  description       = "Permite trafego de saida do RDS"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_mysql.id
}

# =============================================================================
# Security Group - Lambda
# =============================================================================

resource "aws_security_group" "lambda" {
  name        = "${local.name}-lambda-sg"
  description = "Security group para Lambda functions que acessam o RDS"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-lambda-sg"
      Type = "lambda"
    }
  )
}

# Regras de Egress - Lambda
resource "aws_security_group_rule" "lambda_egress_all" {
  description       = "Permite todo trafego de saida do Lambda"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda.id
}

# =============================================================================
# Security Group - ALB (Application Load Balancer)
# =============================================================================

resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "Security group para Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-alb-sg"
      Type = "alb"
    }
  )
}

# Regras de Ingress - ALB
resource "aws_security_group_rule" "alb_ingress_http" {
  description       = "Permite HTTP da internet"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_https" {
  description       = "Permite HTTPS da internet"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# Regras de Egress - ALB para EKS Nodes
resource "aws_security_group_rule" "alb_egress_eks" {
  description              = "Permite trafego do ALB para os worker nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.alb.id
}

# Regra adicional - EKS Nodes aceita trafego do ALB
resource "aws_security_group_rule" "eks_nodes_ingress_alb" {
  description              = "Permite trafego do ALB para os worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.eks_nodes.id
}
