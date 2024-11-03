variable "proxmox" {
  description = "Proxmox configuration"
  type = object({
    endpoint  = string
    insecure  = bool
    username  = string
    password  = optional(string)
    api_token = optional(string)
    ssh_agent = optional(string, false)
  })
  sensitive = true
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    gateway  = string
    cidr     = number
    vlan_id  = optional(number, null)
    name     = string
    endpoint = string
  })
}

variable "vms" {
  description = "VMs configuration"
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
    install_disk   = string
    hostname       = optional(string)
  }))
}

variable "pci" {
  description = "Mapping PCI configuration"
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

variable "github" {
  description = "Github Flux GitOps configuration"
  type = object({
    token      = string
    org        = string
    repository = string
  })
  default = null
}
