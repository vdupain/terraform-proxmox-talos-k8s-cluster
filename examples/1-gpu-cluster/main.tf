module "talos-k8s-cluster" {
  source  = "vdupain/talos-k8s-cluster/proxmox"
  version = "1.0.0-rc4"

  cluster = {
    name     = "gpu-cluster"
    gateway  = "192.168.10.1"
    cidr     = 24
    endpoint = "192.168.10.220"
  }

  vms = {
    "k8s-cp-0" = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      ip             = "192.168.10.220"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-0"
    }
    "k8s-cp-1" = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      ip             = "192.168.10.221"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-1"
    }
    "k8s-cp-2" = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      ip             = "192.168.10.222"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-2"
    }
    "k8s-worker-gpu" = {
      host_node      = "pve3"
      machine_type   = "worker"
      ip             = "192.168.10.223"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 20
      data_disk_size = 20
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "worker-gpu"
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
