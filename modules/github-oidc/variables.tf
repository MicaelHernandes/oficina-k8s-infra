variable "project" {
  description = "Prefixo do projeto."
  type        = string
}

variable "account_id" {
  description = "ID da conta AWS."
  type        = string
}

variable "github_owner" {
  description = "Owner/organização no GitHub."
  type        = string
}

variable "repos" {
  description = "Lista de repositórios que recebem uma role OIDC."
  type        = list(string)
}

variable "tags" {
  description = "Tags padrão."
  type        = map(string)
}
