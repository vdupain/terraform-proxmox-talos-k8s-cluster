module "talos-k8s-cluster" {
  source  = "vdupain/talos-k8s-cluster/proxmox"
  version = "1.0.0-rc1"

  cluster = {
    name     = "cluster-gpu"
    gateway  = "192.168.10.1"
    cidr     = 24
    endpoint = "192.168.10.210"
  }

  vms = {
    "k8s-cp-0" = {
      host_node      = "pve"
      machine_type   = "controlplane"
      ip             = "192.168.10.210"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-0"
    }
    "k8s-cp-1" = {
      host_node      = "pve"
      machine_type   = "controlplane"
      ip             = "192.168.10.211"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-1"
    }
    "k8s-cp-2" = {
      host_node      = "pve"
      machine_type   = "controlplane"
      ip             = "192.168.10.212"
      cpu            = 4
      ram_dedicated  = 8196
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-2"
    }
    "k8s-worker-gpu" = {
      host_node      = "pve"
      machine_type   = "worker"
      ip             = "192.168.10.213"
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
      node         = "pve"
      path         = "0000:bd:00.0"
      subsystem_id = "10de:1522"
    }
  }

  proxmox = {
    endpoint = "https://pve.domain:8006"
    insecure = true
    username = "user"
    password = "password"
    # using PROXMOX_VE_USERNAME instead of api token
    # https://github.com/Telmate/terraform-provider-proxmox/issues/764
    # see .envrc
    #api_token    = "user@pve!terraform=secret"
    api_token = null
  }

  github = {
    token      = "github_pat"
    org        = "username"
    repository = "repository"
  }


}
