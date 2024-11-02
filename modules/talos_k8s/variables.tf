variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name     = string
    endpoint = string
  })
}

variable "nodes" {
  description = "Configuration for worker nodes"
  type = map(object({
    install_disk = string
    hostname     = optional(string)
    machine_type = string
    ip           = string
    gpu          = optional(bool, false)
  }))
}
