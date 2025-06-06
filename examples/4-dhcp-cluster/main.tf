module "talos_k8s_cluster" {
  source  = "vdupain/talos-k8s-cluster/proxmox"
  version = "1.6.0"

  cluster = {
    name         = "dhcp-cluster"
    network_dhcp = true
  }

  vms = {
    cp-0 = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      cpu            = 4
      ram_dedicated  = 4096
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
    }
  }

  proxmox = var.proxmox

}
