variable "aws_region" {
  type        = string
  description = "AWS region used by the providers and addons"
  default     = "us-east-1" # ajuste se estiver usando outra região
}

variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS para os addons (cluster-autoscaler, ALB, etc.)"
}