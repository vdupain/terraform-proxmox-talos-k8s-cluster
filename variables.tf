variable "proxmox" {
  description = "Proxmox configuration"
  type = object({
    endpoint      = optional(string)
    insecure      = optional(bool)
    username      = optional(string)
    password      = optional(string)
    api_token     = optional(string)
    ssh_agent     = optional(string, false)
    random_vm_ids = optional(string, false)
  })
  sensitive = true
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                  = string
    talos_version         = optional(string, "v1.9.4")
    network_dhcp          = optional(bool, false)
    gateway               = optional(string)
    cidr                  = optional(number)
    vlan_id               = optional(number, null)
    network_device_bridge = optional(string, "vmbr0")
    endpoint              = optional(string)
  })
}

variable "vms" {
  description = "VMs configuration"
  type = map(object({
    host_node      = string
    machine_type   = string
    datastore_id   = optional(string, "local-lvm")
    ip             = optional(string)
    cpu            = number
    ram_dedicated  = number
    os_disk_size   = optional(number, 10)
    data_disk_size = optional(number, 20)
    install_disk   = optional(string, "/dev/sda")
    gpu            = optional(string)
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

variable "gitops" {
  description = "GitOps configuration"
  type = object({
    repository   = string
    token        = string
    cluster_name = string
  })
  default = null
}

variable "certificate" {
  description = "Certificate for k8s sealed-secrets"
  type = object({
    cert = string
    key  = string
  })
  default = null
}
