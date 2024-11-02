variable "proxmox" {
  type = object({
    endpoint  = string
    insecure  = bool
    username  = string
    password  = string
    api_token = string
  })
  sensitive = true
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name    = string
    gateway = string
    cidr    = number
    vlan_id = optional(number, null)
  })
}

variable "vms" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node      = string
    machine_type   = string
    datastore_id   = optional(string, "local-lvm")
    ip             = string
    cpu            = number
    ram_dedicated  = number
    os_disk_size   = number
    data_disk_size = number
    gpu            = optional(bool, false)
  }))
}

variable "pci" {
  description = "Configuration mapping PCI"
  type = map(object({
    name         = string
    id           = string
    iommu_group  = number
    node         = string
    path         = string
    subsystem_id = string
  }))
  default = null
}
