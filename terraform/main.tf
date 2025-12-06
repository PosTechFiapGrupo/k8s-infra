# =============================================================================
# Main Terraform Configuration
# =============================================================================
# Este arquivo orquestra todos os módulos da infraestrutura

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# =============================================================================
# Módulo VPC
# =============================================================================

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  additional_tags      = var.additional_tags
}

# =============================================================================
# Módulo Security Groups
# =============================================================================

module "security_groups" {
  source = "./modules/security-groups"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = var.vpc_cidr
  additional_tags = var.additional_tags
}

# =============================================================================
# Módulo EKS
# =============================================================================

module "eks" {
  source = "./modules/eks"

  project_name           = var.project_name
  environment            = var.environment
  cluster_version        = var.eks_cluster_version
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  eks_security_group_id  = module.security_groups.eks_cluster_sg_id
  node_security_group_id = module.security_groups.eks_nodes_sg_id
  node_instance_types    = var.eks_node_instance_types
  node_desired_size      = var.eks_node_desired_size
  node_min_size          = var.eks_node_min_size
  node_max_size          = var.eks_node_max_size
  node_disk_size         = var.eks_node_disk_size
  additional_tags        = var.additional_tags

  depends_on = [module.vpc, module.security_groups]
}

# =============================================================================
# Locals
# =============================================================================

locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}
