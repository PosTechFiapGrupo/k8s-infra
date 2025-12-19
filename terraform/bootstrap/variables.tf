variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev/stage/prod/lab)"
}

variable "aws_region" {
  type        = string
  description = "Região AWS"
}

variable "additional_tags" {
  type        = map(string)
  description = "Tags adicionais"
  default     = {}
}

# Se quiser forçar um nome fixo (normalmente deixe vazio)
variable "bucket_name_override" {
  type    = string
  default = ""
}
