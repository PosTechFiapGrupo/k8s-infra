# =============================================================================
# Módulo EKS - Variáveis
# =============================================================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para os worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "ID do Security Group do EKS Cluster"
  type        = string
}

variable "node_security_group_id" {
  description = "ID do Security Group dos Worker Nodes"
  type        = string
}

variable "node_instance_types" {
  description = "Tipos de instância EC2 para os worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Número desejado de worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Número mínimo de worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Número máximo de worker nodes"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Tamanho do disco dos worker nodes em GB"
  type        = number
  default     = 50
}

variable "node_capacity_type" {
  description = "Tipo de capacidade dos nodes (ON_DEMAND ou SPOT)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Capacity type deve ser ON_DEMAND ou SPOT."
  }
}

variable "enable_cluster_encryption" {
  description = "Habilitar encryption para secrets do cluster"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Habilitar acesso privado ao endpoint do cluster"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Habilitar acesso público ao endpoint do cluster"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Lista de CIDRs que podem acessar o endpoint público"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
