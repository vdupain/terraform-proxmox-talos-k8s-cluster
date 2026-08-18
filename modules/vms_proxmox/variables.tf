variable "proxmox" {
  description = "Proxmox configuration"
  type = object({
    endpoint           = string
    insecure           = bool
    username           = string
    password           = optional(string)
    api_token          = optional(string)
    ssh_agent          = optional(string, false)
    random_vm_ids      = optional(string, false)
    random_vm_id_start = optional(number, 1000)
    random_vm_id_end   = optional(number, 2000)
  })
  sensitive = true
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    network_dhcp          = optional(bool, false)
    gateway               = string
    dns_domain            = optional(string, null)
    dns_servers           = optional(list(string), null)
    cidr                  = number
    vlan_id               = optional(number, null)
    mtu                   = optional(number, null)
    network_device_bridge = optional(string, "vmbr0")
    name                  = string
    talos_version         = string
  })
}

variable "additional_extensions" {
  description = "Additional Talos system extensions to include in all images (added to base + GPU-specific extensions)"
  type        = list(string)
  default     = []
}

variable "vms" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node        = string
    machine_type     = string
    datastore_id     = optional(string, "local-lvm")
    ip               = string
    cpu              = number
    memory_dedicated = number
    system_disk_size = number
    user_disk_size   = number
    disk_file_format = optional(string, "raw")
    gpu              = optional(string)
  }))
}

variable "pci" {
  description = "Configuration mapping PCI"
  type = map(object({
    name             = string
    id               = string
    iommu_group      = number
    node             = string
    path             = string
    subsystem_id     = string
    mediated_devices = optional(bool, false)
  }))
  default = null
}
