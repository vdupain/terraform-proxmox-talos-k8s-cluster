variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name         = string
    endpoint     = string
    install_disk = string
    network_dhcp = optional(bool, false)
  })
}

variable "nodes" {
  description = "Configuration for worker nodes"
  type = map(object({
    hostname     = optional(string)
    machine_type = string
    ip           = string
    gpu          = optional(bool, false)
  }))
}
