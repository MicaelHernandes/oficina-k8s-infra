plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Child modules herdam required_version/providers da raiz; não exigimos a
# declaração repetida em cada módulo (evita ruído sem ganho real).
rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}
