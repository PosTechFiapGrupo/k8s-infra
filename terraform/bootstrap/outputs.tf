output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "Nome do bucket do state remoto"
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "Account ID atual"
}

output "aws_region" {
  value       = var.aws_region
  description = "Região AWS usada"
}

output "environment" {
  value       = var.environment
  description = "Ambiente usado"
}
