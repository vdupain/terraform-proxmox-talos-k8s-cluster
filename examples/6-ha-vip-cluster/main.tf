module "talos_k8s_cluster" {
  #  source  = "vdupain/talos-k8s-cluster/proxmox"
  #  version = "1.8.0"
  source = "../.."

  cluster = {
    name     = "ha-vip-cluster"
    gateway  = "192.168.10.1"
    cidr     = 24
    vip_ip   = "192.168.10.200" # Virtual IP for HA control plane
    vip_interface = "eth0"      # Network interface for VIP

    # VIP becomes the cluster endpoint automatically (priority over explicit endpoint)
    # endpoint = "192.168.10.200" # Not needed - VIP is used as endpoint

    allow_scheduling_on_control_planes = false # Dedicated control plane nodes

    talos_version = "v1.12.1"
  }

  # HA Control Plane - 3 nodes for quorum
  vms = {
    cp-01 = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      ip             = "192.168.10.210"
      cpu            = 4
      ram_dedicated  = 8192
      os_disk_size   = 20
      data_disk_size = 50
      datastore_id   = "local-lvm"
    }
    cp-02 = {
      host_node      = "pve2"
      machine_type   = "controlplane"
      ip             = "192.168.10.211"
      cpu            = 4
      ram_dedicated  = 8192
      os_disk_size   = 20
      data_disk_size = 50
      datastore_id   = "local-lvm"
    }
    cp-03 = {
      host_node      = "pve3"
      machine_type   = "controlplane"
      ip             = "192.168.10.212"
      cpu            = 4
      ram_dedicated  = 8192
      os_disk_size   = 20
      data_disk_size = 50
      datastore_id   = "local-lvm"
    }

    # Worker nodes
    worker-01 = {
      host_node      = "pve1"
      machine_type   = "worker"
      ip             = "192.168.10.220"
      cpu            = 8
      ram_dedicated  = 16384
      os_disk_size   = 20
      data_disk_size = 100
      datastore_id   = "local-lvm"
    }
    worker-02 = {
      host_node      = "pve2"
      machine_type   = "worker"
      ip             = "192.168.10.221"
      cpu            = 8
      ram_dedicated  = 16384
      os_disk_size   = 20
      data_disk_size = 100
      datastore_id   = "local-lvm"
    }
    worker-03 = {
      host_node      = "pve3"
      machine_type   = "worker"
      ip             = "192.168.10.222"
      cpu            = 8
      ram_dedicated  = 16384
      os_disk_size   = 20
      data_disk_size = 100
      datastore_id   = "local-lvm"
    }
  }

  # Optional: Add additional Talos extensions to all nodes
  # additional_extensions = [
  #   "siderolabs/intel-ucode",
  #   "siderolabs/iscsi-tools"
  # ]

  proxmox = var.proxmox

  # Optional: GitOps with FluxCD
  # gitops = var.gitops

  # Optional: Sealed Secrets
  # certificate = var.certificate
}
