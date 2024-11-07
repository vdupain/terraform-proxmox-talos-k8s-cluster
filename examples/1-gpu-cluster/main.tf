module "talos_k8s_cluster" {
  #  source  = "vdupain/talos-k8s-cluster/proxmox"
  #  version = "1.0.0"
  source = "../.."

  cluster = {
    name         = "gpu-cluster"
    network_dhcp = false
    gateway      = "192.168.10.1"
    cidr         = 24
    endpoint     = "192.168.10.220"
  }

  vms = {
    cp-0 = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      ip             = "192.168.10.220"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
    }
    cp-1 = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      ip             = "192.168.10.221"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
    }
    cp-2 = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      ip             = "192.168.10.222"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
    }
    nvidia-3060 = {
      host_node      = "pve3"
      machine_type   = "worker"
      ip             = "192.168.10.223"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
      gpu            = "nvidia_3060"
    }
    # nvidia-k4200 = {
    #   host_node      = "pve3"
    #   machine_type   = "worker"
    #   ip             = "192.168.10.224"
    #   cpu            = 4
    #   ram_dedicated  = 8196
    #   os_disk_size   = 20
    #   data_disk_size = 20
    #   datastore_id   = "local-lvm"
    #   gpu            = "nvidia_k4200"
    # }

  }

  pci = {
    nvidia_3060 = {
      name         = "nvidia_3060"
      id           = "10de:2503"
      iommu_group  = 2
      node         = "pve3"
      path         = "0000:bd:00.0"
      subsystem_id = "10de:1522"
    }
    nvidia_k4200 = {
      name         = "nvidia_k4200"
      id           = "10de:11b4"
      iommu_group  = 4
      node         = "pve3"
      path         = "0000:4f:00.0"
      subsystem_id = "10de:1096"
    }
  }

  proxmox = var.proxmox
  gitops  = var.gitops
}
