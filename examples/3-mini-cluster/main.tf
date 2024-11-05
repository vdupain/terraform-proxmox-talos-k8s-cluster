module "talos-k8s-cluster" {
  source  = "vdupain/talos-k8s-cluster/proxmox"
  version = "1.0.0-rc6"

  cluster = {
    name     = "mini-cluster"
    gateway  = "192.168.10.1"
    cidr     = 24
    endpoint = "192.168.10.50"
  }

  vms = {
    "k8s-cp-0" = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      ip             = "192.168.10.50"
      cpu            = 4
      ram_dedicated  = 4096
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-0"
    }
  }

  proxmox = var.proxmox
}