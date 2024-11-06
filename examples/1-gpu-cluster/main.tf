module "talos-k8s-cluster" {
  #source  = "vdupain/talos-k8s-cluster/proxmox"
  #version = "1.0.0-rc6"
  source = "../.."

  cluster = {
    name         = "gpu-cluster"
    network_dhcp = true
  }

  vms = {
    "k8s-cp-0" = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
    }
    "k8s-cp-1" = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
    }
    "k8s-cp-2" = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
    }
    "k8s-worker-gpu" = {
      host_node      = "pve3"
      machine_type   = "worker"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
      gpu            = true
    }

  }

  pci = {
    "nvidia_3060" = {
      name         = "nvidia_3060"
      id           = "10de:2503"
      iommu_group  = 2
      node         = "pve3"
      path         = "0000:bd:00.0"
      subsystem_id = "10de:1522"
    }
  }

  proxmox = var.proxmox
  github  = var.github
}
