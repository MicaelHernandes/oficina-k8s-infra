variable "repository_name" {
  description = "Nome do repositório ECR."
  type        = string
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
}
