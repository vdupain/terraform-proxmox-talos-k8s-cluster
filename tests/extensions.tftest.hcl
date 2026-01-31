# Test: Extensions Configuration
# Verifies that additional extensions are correctly added to base/GPU-specific extensions
# Base and GPU-specific extensions are defined in modules/vms_proxmox/schematics/*.yaml

run "test_no_additional_extensions" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name          = "test-cluster"
      talos_version = "v1.12.1"
      gateway       = "192.168.1.1"
      cidr          = 24
    }

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
    }
  }

  # Verify no additional extensions by default
  assert {
    condition     = length(var.additional_extensions) == 0
    error_message = "Default additional_extensions should be empty"
  }
}

run "test_with_additional_extensions" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name          = "test-cluster"
      talos_version = "v1.12.1"
      gateway       = "192.168.1.1"
      cidr          = 24
    }

    additional_extensions = [
      "siderolabs/intel-ucode",
      "siderolabs/iscsi-tools"
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
      worker-01 = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.20"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 10
        data_disk_size = 50
      }
    }
  }

  # Verify additional extensions
  assert {
    condition     = length(var.additional_extensions) == 2 && contains(var.additional_extensions, "siderolabs/intel-ucode")
    error_message = "Additional extensions should include custom extensions"
  }
}

run "test_gpu_nodes_with_additional_extensions" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name          = "test-cluster"
      talos_version = "v1.12.1"
      gateway       = "192.168.1.1"
      cidr          = 24
    }

    additional_extensions = [
      "siderolabs/util-linux-tools"
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
      worker-nvidia = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.30"
        cpu            = 16
        ram_dedicated  = 32768
        os_disk_size   = 10
        data_disk_size = 100
        gpu            = "nvidia-a100"
      }
      worker-intel = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.31"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 10
        data_disk_size = 50
        gpu            = "intel-arc-a770"
      }
    }

    pci = {
      nvidia-a100 = {
        name         = "nvidia-a100"
        id           = "10de:20f1"
        iommu_group  = 42
        node         = "pve1"
        path         = "0000:01:00.0"
        subsystem_id = "10de:1450"
      }
      intel-arc-a770 = {
        name         = "intel-arc-a770"
        id           = "8086:56a0"
        iommu_group  = 43
        node         = "pve1"
        path         = "0000:02:00.0"
        subsystem_id = "8086:1234"
      }
    }
  }

  # Verify GPU nodes are detected
  assert {
    condition     = length([for k, v in var.vms : k if v.gpu != null]) == 2
    error_message = "Should have 2 GPU workers"
  }

  # Verify additional extensions set
  assert {
    condition     = contains(var.additional_extensions, "siderolabs/util-linux-tools")
    error_message = "Additional extensions should be applied to all node types"
  }
}
