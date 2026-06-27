variable "proxmox" {
  description = "Proxmox configuration"
  type = object({
    endpoint           = optional(string)
    insecure           = optional(bool)
    username           = optional(string)
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
    name                               = string
    talos_version                      = optional(string, "v1.13.4")
    network_dhcp                       = optional(bool, false)
    gateway                            = optional(string)
    dns_domain                         = optional(string)
    dns_servers                        = optional(list(string))
    cidr                               = optional(number)
    vlan_id                            = optional(number, null)
    network_device_bridge              = optional(string, "vmbr0")
    endpoint                           = optional(string)
    allow_scheduling_on_control_planes = optional(bool, true)
    vip_ip                             = optional(string)
    vip_interface                      = optional(string, "eth0")
  })
}

variable "additional_extensions" {
  description = "Additional Talos system extensions to include in all images (added to base + GPU-specific extensions defined in modules/vms_proxmox/schematics/)"
  type        = list(string)
  default     = []
}

variable "vms" {
  description = "VMs configuration"
  type = map(object({
    host_node        = string
    machine_type     = string
    datastore_id     = optional(string, "local-lvm")
    ip               = optional(string)
    cpu              = number
    memory_dedicated = number
    system_disk_size = optional(number, 10)
    user_disk_size   = optional(number, 20)
    install_disk     = optional(string, "/dev/sda")
    disk_file_format = optional(string, "raw")
    gpu              = optional(string)
  }))
}

variable "pci" {
  description = "Mapping PCI configuration"
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
