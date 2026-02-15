module "talos_k8s_cluster" {
  #  source  = "vdupain/talos-k8s-cluster/proxmox"
  #  version = "2.0.0"
  source = "../.."

  cluster = {
    name         = "vars-from-envrc-cluster"
    network_dhcp = true
  }

  vms = {
    "k8s-cp-0" = {
      host_node        = "pve1"
      machine_type     = "controlplane"
      cpu              = 2
      memory_dedicated = 4096
      system_disk_size = 10
      user_disk_size   = 10
      datastore_id     = "local-lvm"
    }
  }

  proxmox = {
    # using env variables
  }

  gitops = {
    repository   = "https://github.com/vdupain/gitops.git"
    token        = var.github_pat
    cluster_name = "vars-from-envrc-cluster"
  }

}
