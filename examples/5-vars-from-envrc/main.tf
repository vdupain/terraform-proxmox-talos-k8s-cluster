module "talos-k8s-cluster" {
  #source  = "vdupain/talos-k8s-cluster/proxmox"
  #version = "1.0.0-rc7"
  source = "../.."

  cluster = {
    name         = "vars-from-envrc-cluster"
    network_dhcp = true
  }

  vms = {
    "k8s-cp-0" = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      cpu            = 2
      ram_dedicated  = 4096
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
    }
  }

  proxmox =  {
    # using env variables
  }

}
