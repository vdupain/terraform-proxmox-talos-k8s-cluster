plugin "terraform" {
    enabled = true
    preset = "all"
}

rule "terraform_naming_convention" {
  enabled = true
  format = "snake_case"
}

rule "terraform_required_version" {
  enabled = false
}