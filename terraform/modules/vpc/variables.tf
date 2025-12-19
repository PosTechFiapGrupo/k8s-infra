# =============================================================================
# Módulo VPC - Variáveis
# =============================================================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de Availability Zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks das subnets privadas"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks das subnets públicas"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para subnets privadas"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Usar apenas um NAT Gateway (economia de custos)"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support na VPC"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}


variable "enable_vpc_flow_logs" {
  description = "Habilita VPC Flow Logs (requer IAM/CloudWatch)."
  type        = bool
  default     = false
}