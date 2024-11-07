variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name         = string
    endpoint     = string
    network_dhcp = optional(bool, false)
  })
}

variable "nodes" {
  description = "Configuration for worker nodes"
  type = map(object({
    machine_type = string
    ip           = string
    install_disk = optional(string, "/dev/sda")
    gpu          = optional(string)
  }))
}
