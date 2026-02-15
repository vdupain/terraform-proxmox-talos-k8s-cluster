module "talos_k8s_cluster" {
  #  source  = "vdupain/talos-k8s-cluster/proxmox"
  #  version = "2.0.0"
  source = "../.."

  cluster = {
    name     = "mini-cluster"
    gateway  = "192.168.10.1"
    cidr     = 24
    endpoint = "192.168.10.50"
  }

  vms = {
    "k8s-cp-0" = {
      host_node        = "pve1"
      machine_type     = "controlplane"
      ip               = "192.168.10.50"
      cpu              = 4
      memory_dedicated = 4096
      system_disk_size = 10
      user_disk_size   = 10
      datastore_id     = "local-lvm"
    }
  }

  proxmox = var.proxmox
}
