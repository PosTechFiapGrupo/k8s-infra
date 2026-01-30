provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}


locals {
  tfstate_bucket_name = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.tfstate_bucket_name

  tags = merge(
    { Name = "Terraform State Bucket" },
    local.common_tags
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    { Name = "Terraform State Lock Table" },
    local.common_tags
  )
}
