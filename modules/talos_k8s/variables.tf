variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                               = string
    endpoint                           = optional(string)
    network_dhcp                       = optional(bool, false)
    allow_scheduling_on_control_planes = optional(bool, true)
    vip_ip                             = optional(string)
    vip_interface                      = optional(string, "eth0")
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
