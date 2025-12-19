# =============================================================================
# Variáveis Globais
# =============================================================================

variable "project_name" {
  description = "Nome do projeto usado para naming de recursos"
  type        = string
  default     = "tech-challenge"
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment deve ser: dev, staging ou prod."
  }
}

variable "aws_region" {
  description = "Região AWS para deploy dos recursos"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# Variáveis VPC
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Lista de Availability Zones para usar"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks das subnets privadas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks das subnets públicas"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# =============================================================================
# Variáveis EKS
# =============================================================================

variable "eks_cluster_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_types" {
  description = "Tipos de instância EC2 para os worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Número desejado de worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Número mínimo de worker nodes"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Número máximo de worker nodes"
  type        = number
  default     = 4
}

variable "eks_node_disk_size" {
  description = "Tamanho do disco dos worker nodes em GB"
  type        = number
  default     = 50
}

# =============================================================================
# Variáveis de Database
# =============================================================================

variable "rds_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Armazenamento alocado para RDS em GB"
  type        = number
  default     = 20
}

variable "rds_engine_version" {
  description = "Versão do MySQL para RDS"
  type        = string
  default     = "8.0"
}

variable "rds_database_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "tech_challenge"
}

variable "rds_username" {
  description = "Username master do RDS"
  type        = string
  default     = "admin"
  sensitive   = true
}

# =============================================================================
# Tags Adicionais
# =============================================================================

variable "additional_tags" {
  description = "Tags adicionais para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

variable "enable_vpc_flow_logs" {
  description = "Habilita VPC Flow Logs (requer permissões IAM/CloudWatch)."
  type        = bool
  default     = false
}

variable "enable_eks" {
  description = "Habilita criação do EKS (requer permissões IAM)."
  type        = bool
  default     = true
}