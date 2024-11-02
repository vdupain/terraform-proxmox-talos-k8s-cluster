variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name = string
  })
}

variable "github" {
  description = "Github configuration"
  type = object({
    token      = string
    org        = string
    repository = string
  })
}
