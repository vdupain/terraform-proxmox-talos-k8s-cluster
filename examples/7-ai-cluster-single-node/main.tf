module "talos_k8s_cluster" {
  #  source  = "vdupain/talos-k8s-cluster/proxmox"
  #  version = "2.0.0"
  source = "../.."

  cluster = {
    name     = "ai-cluster"
    gateway  = "192.168.10.1"
    cidr     = 24
    endpoint = "192.168.10.203"
  }

  vms = {
    "cp-0" = {
      host_node        = "pve3"
      machine_type     = "controlplane"
      ip               = "192.168.10.203"
      cpu              = 8
      memory_dedicated = 16384
      system_disk_size = 20
      user_disk_size   = 20
      datastore_id     = "local-zfs"
      gpu              = "nvidia_3060"
    }
  }

  # GPU extensions are automatically included based on GPU type detection
  # NVIDIA GPUs get: base + nvidia extensions (from schematics/)
  # Base nodes get: base extensions only

  pci = {
    nvidia_3060 = {
      name         = "nvidia_3060"
      id           = "10de:2503"
      iommu_group  = 2
      node         = "pve3"
      path         = "0000:b3:00.0"
      subsystem_id = "10de:1522"
    }
  }

  proxmox = var.proxmox
  gitops  = var.gitops
}
