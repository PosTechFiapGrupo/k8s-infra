# =============================================================================
# Backend Remoto do Terraform (S3)
# =============================================================================
# Este arquivo configura o backend remoto para armazenar o state do Terraform
# de forma segura e permitir trabalho em equipe com locking.

terraform {
  backend "s3" {}
}
