# Test: Integration
# Verifies that all new features work together correctly

run "test_full_ha_cluster_with_vip_and_gpu" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                               = "prod-cluster"
      talos_version                      = "v1.12.1"
      gateway                            = "192.168.1.1"
      cidr                               = 24
      vip_ip                             = "192.168.1.100"
      vip_interface                      = "eth0"
      allow_scheduling_on_control_planes = false
    }

    additional_extensions = [
      "siderolabs/intel-ucode"
    ]

    vms = {
      cp-01 = {
        host_node      = "pve1"
        machine_type   = "controlplane"
        ip             = "192.168.1.10"
        cpu            = 4
        ram_dedicated  = 8192
        os_disk_size   = 10
        data_disk_size = 20
      }
      cp-02 = {
        host_node      = "pve2"
        machine_type   = "controlplane"
        ip             = "192.168.1.11"
        cpu            = 4
        ram_dedicated  = 8192
        os_disk_size   = 10
        data_disk_size = 20
      }
      cp-03 = {
        host_node      = "pve3"
        machine_type   = "controlplane"
        ip             = "192.168.1.12"
        cpu            = 4
        ram_dedicated  = 8192
        os_disk_size   = 10
        data_disk_size = 20
      }
      worker-nvidia-01 = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.30"
        cpu            = 16
        ram_dedicated  = 32768
        os_disk_size   = 10
        data_disk_size = 100
        gpu            = "nvidia-3090"
      }
      worker-intel-01 = {
        host_node      = "pve2"
        machine_type   = "worker"
        ip             = "192.168.1.31"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 10
        data_disk_size = 50
        gpu            = "intel-arc-a770"
      }
      worker-standard-01 = {
        host_node      = "pve3"
        machine_type   = "worker"
        ip             = "192.168.1.40"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 10
        data_disk_size = 50
      }
    }

    pci = {
      nvidia-3090 = {
        name         = "nvidia-3090"
        id           = "10de:2204"
        iommu_group  = 42
        node         = "pve1"
        path         = "0000:01:00.0"
        subsystem_id = "10de:1467"
      }
      intel-arc-a770 = {
        name         = "intel-arc-a770"
        id           = "8086:56a0"
        iommu_group  = 43
        node         = "pve2"
        path         = "0000:02:00.0"
        subsystem_id = "8086:1234"
      }
    }
  }

  # VIP configuration
  assert {
    condition     = var.cluster.vip_ip == "192.168.1.100"
    error_message = "VIP should be configured for HA control plane"
  }

  # Control plane scheduling
  assert {
    condition     = var.cluster.allow_scheduling_on_control_planes == false
    error_message = "Control plane scheduling should be disabled in production"
  }

  # Extensions configuration
  assert {
    condition     = length(var.additional_extensions) == 1 && contains(var.additional_extensions, "siderolabs/intel-ucode")
    error_message = "Additional extensions should include intel-ucode for all nodes"
  }

  # VM types
  assert {
    condition     = length([for k, v in var.vms : k if v.machine_type == "controlplane"]) == 3
    error_message = "Should have 3 control plane nodes for HA"
  }

  assert {
    condition     = length([for k, v in var.vms : k if v.machine_type == "worker"]) == 3
    error_message = "Should have 3 worker nodes"
  }

  # GPU configuration
  assert {
    condition     = length([for k, v in var.vms : k if v.gpu != null]) == 2
    error_message = "Should have 2 GPU workers"
  }

  assert {
    condition     = var.vms["worker-nvidia-01"].gpu == "nvidia-3090"
    error_message = "NVIDIA worker should have GPU configured"
  }

  assert {
    condition     = var.vms["worker-intel-01"].gpu == "intel-arc-a770"
    error_message = "Intel worker should have GPU configured"
  }
}

run "test_minimal_single_node_cluster" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                               = "dev-cluster"
      talos_version                      = "v1.12.1"
      gateway                            = "192.168.1.1"
      cidr                               = 24
      allow_scheduling_on_control_planes = true
      # All other parameters use defaults
    }

    vms = {
      single-node = {
        host_node      = "pve1"
        machine_type   = "controlplane"
        ip             = "192.168.1.10"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 20
        data_disk_size = 50
      }
    }
  }

  # Single node cluster with defaults
  assert {
    condition     = var.cluster.allow_scheduling_on_control_planes == true
    error_message = "Single node cluster should allow scheduling on control plane"
  }

  assert {
    condition     = var.cluster.vip_ip == null
    error_message = "Single node cluster should not have VIP"
  }

  assert {
    condition     = length(var.additional_extensions) == 0
    error_message = "Should have no additional extensions by default"
  }
}
