# Test: Extension Merging Logic
# Verifies that extensions are correctly merged based on GPU type
# - Base nodes: base + additional
# - NVIDIA nodes: base + nvidia + additional
# - Intel nodes: base + intel + additional

run "test_base_only_no_additional_extensions" {
  command = plan

  module {
    source = "./modules/vms_proxmox"
  }

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                  = "test-cluster"
      gateway               = "192.168.1.1"
      cidr                  = 24
      talos_version         = "v1.12.1"
      network_device_bridge = "vmbr0"
    }

    # No additional_extensions provided (defaults to [])

    vms = {
      worker-base = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.20"
        cpu            = 4
        ram_dedicated  = 8192
        os_disk_size   = 10
        data_disk_size = 20
        # No GPU specified
      }
    }
  }

  # Verify GPU type is base
  assert {
    condition     = local.vm_gpu_types["worker-base"] == "base"
    error_message = "Worker without GPU should have 'base' GPU type"
  }

  # Verify only base type is used
  assert {
    condition     = length(local.used_gpu_types) == 1 && contains(local.used_gpu_types, "base")
    error_message = "Should only use 'base' GPU type when no GPUs configured"
  }

  # Verify base extensions include exactly base schematic extensions (qemu-guest-agent, zfs)
  # No GPU-specific or additional extensions should be included
  assert {
    condition = (
      length(local.extensions_by_type["base"]) == 2 &&
      contains(local.extensions_by_type["base"], "siderolabs/qemu-guest-agent") &&
      contains(local.extensions_by_type["base"], "siderolabs/zfs")
    )
    error_message = "Base type should only include base schematic extensions (qemu-guest-agent, zfs) when no additional extensions"
  }
}

run "test_base_with_additional_extensions" {
  command = plan

  module {
    source = "./modules/vms_proxmox"
  }

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                  = "test-cluster"
      gateway               = "192.168.1.1"
      cidr                  = 24
      talos_version         = "v1.12.1"
      network_device_bridge = "vmbr0"
    }

    additional_extensions = [
      "siderolabs/intel-ucode",
      "siderolabs/iscsi-tools"
    ]

    vms = {
      worker-base = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.20"
        cpu            = 4
        ram_dedicated  = 8192
        os_disk_size   = 10
        data_disk_size = 20
        # No GPU specified
      }
    }
  }

  # Verify base extensions include base + additional (4 total)
  assert {
    condition = (
      length(local.extensions_by_type["base"]) == 4 &&
      contains(local.extensions_by_type["base"], "siderolabs/qemu-guest-agent") &&
      contains(local.extensions_by_type["base"], "siderolabs/zfs") &&
      contains(local.extensions_by_type["base"], "siderolabs/intel-ucode") &&
      contains(local.extensions_by_type["base"], "siderolabs/iscsi-tools")
    )
    error_message = "Base type should include base schematic + additional extensions (4 total)"
  }

  # Verify no GPU-specific extensions are included
  assert {
    condition = (
      !contains(local.extensions_by_type["base"], "siderolabs/nvidia-container-toolkit-production") &&
      !contains(local.extensions_by_type["base"], "siderolabs/nonfree-kmod-nvidia-production") &&
      !contains(local.extensions_by_type["base"], "siderolabs/intel-gpu-firmware")
    )
    error_message = "Base type should NOT include GPU-specific extensions"
  }
}

run "test_nvidia_extension_merging" {
  command = plan

  module {
    source = "./modules/vms_proxmox"
  }

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                  = "test-cluster"
      gateway               = "192.168.1.1"
      cidr                  = 24
      talos_version         = "v1.12.1"
      network_device_bridge = "vmbr0"
    }

    additional_extensions = [
      "siderolabs/util-linux-tools"
    ]

    vms = {
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
    }
  }

  # Verify NVIDIA extensions include base + nvidia + additional (5 total)
  assert {
    condition = (
      length(local.extensions_by_type["nvidia"]) == 5 &&
      # Base extensions
      contains(local.extensions_by_type["nvidia"], "siderolabs/qemu-guest-agent") &&
      contains(local.extensions_by_type["nvidia"], "siderolabs/zfs") &&
      # NVIDIA extensions
      contains(local.extensions_by_type["nvidia"], "siderolabs/nvidia-container-toolkit-production") &&
      contains(local.extensions_by_type["nvidia"], "siderolabs/nonfree-kmod-nvidia-production") &&
      # Additional extensions
      contains(local.extensions_by_type["nvidia"], "siderolabs/util-linux-tools")
    )
    error_message = "NVIDIA type should include base + nvidia + additional extensions (5 total)"
  }
}

run "test_intel_extension_merging" {
  command = plan

  module {
    source = "./modules/vms_proxmox"
  }

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                  = "test-cluster"
      gateway               = "192.168.1.1"
      cidr                  = 24
      talos_version         = "v1.12.1"
      network_device_bridge = "vmbr0"
    }

    additional_extensions = [
      "siderolabs/util-linux-tools"
    ]

    vms = {
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

  # Verify Intel extensions include base + intel + additional (4 total)
  assert {
    condition = (
      length(local.extensions_by_type["intel"]) == 4 &&
      # Base extensions
      contains(local.extensions_by_type["intel"], "siderolabs/qemu-guest-agent") &&
      contains(local.extensions_by_type["intel"], "siderolabs/zfs") &&
      # Intel extensions
      contains(local.extensions_by_type["intel"], "siderolabs/intel-gpu-firmware") &&
      # Additional extensions
      contains(local.extensions_by_type["intel"], "siderolabs/util-linux-tools")
    )
    error_message = "Intel type should include base + intel + additional extensions (4 total)"
  }
}

run "test_mixed_cluster_extension_isolation" {
  command = plan

  module {
    source = "./modules/vms_proxmox"
  }

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                  = "test-cluster"
      gateway               = "192.168.1.1"
      cidr                  = 24
      talos_version         = "v1.12.1"
      network_device_bridge = "vmbr0"
    }

    additional_extensions = [
      "siderolabs/iscsi-tools"
    ]

    vms = {
      worker-base = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.20"
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
        gpu            = "nvidia-3090"
      }
      worker-intel = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.31"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 10
        data_disk_size = 50
        gpu            = "intel-arc"
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
      intel-arc = {
        name         = "intel-arc"
        id           = "8086:56a0"
        iommu_group  = 43
        node         = "pve1"
        path         = "0000:02:00.0"
        subsystem_id = "8086:1234"
      }
    }
  }

  # Verify all three GPU types are used
  assert {
    condition = (
      length(local.used_gpu_types) == 3 &&
      contains(local.used_gpu_types, "base") &&
      contains(local.used_gpu_types, "nvidia") &&
      contains(local.used_gpu_types, "intel")
    )
    error_message = "Mixed cluster should use all three GPU types"
  }

  # Verify base type doesn't have GPU extensions
  assert {
    condition = (
      length(local.extensions_by_type["base"]) == 3 &&
      !contains(local.extensions_by_type["base"], "siderolabs/nvidia-container-toolkit-production") &&
      !contains(local.extensions_by_type["base"], "siderolabs/intel-gpu-firmware")
    )
    error_message = "Base nodes should NOT have GPU-specific extensions in mixed cluster"
  }

  # Verify nvidia type doesn't have Intel extensions
  assert {
    condition = (
      contains(local.extensions_by_type["nvidia"], "siderolabs/nvidia-container-toolkit-production") &&
      !contains(local.extensions_by_type["nvidia"], "siderolabs/intel-gpu-firmware")
    )
    error_message = "NVIDIA nodes should NOT have Intel extensions"
  }

  # Verify intel type doesn't have NVIDIA extensions
  assert {
    condition = (
      contains(local.extensions_by_type["intel"], "siderolabs/intel-gpu-firmware") &&
      !contains(local.extensions_by_type["intel"], "siderolabs/nvidia-container-toolkit-production")
    )
    error_message = "Intel nodes should NOT have NVIDIA extensions"
  }

  # Verify all types have additional extensions
  assert {
    condition = (
      contains(local.extensions_by_type["base"], "siderolabs/iscsi-tools") &&
      contains(local.extensions_by_type["nvidia"], "siderolabs/iscsi-tools") &&
      contains(local.extensions_by_type["intel"], "siderolabs/iscsi-tools")
    )
    error_message = "All node types should have additional extensions"
  }
}
