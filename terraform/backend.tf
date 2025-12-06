# =============================================================================
# Backend Remoto do Terraform (S3 + DynamoDB)
# =============================================================================
# Este arquivo configura o backend remoto para armazenar o state do Terraform
# de forma segura e permitir trabalho em equipe com locking.

terraform {
  backend "s3" {
    bucket         = "tech-challenge-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tech-challenge-terraform-locks"
  }
}

# =============================================================================
# Recursos para criar o backend (executar apenas uma vez, localmente)
# =============================================================================
# Estes recursos devem ser aplicados separadamente antes de configurar o backend S3.
# Execute: terraform apply -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tech-challenge-terraform-state"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tech-challenge-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
