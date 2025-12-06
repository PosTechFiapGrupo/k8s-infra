# =============================================================================
# Módulo Security Groups - Variáveis
# =============================================================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "additional_tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
