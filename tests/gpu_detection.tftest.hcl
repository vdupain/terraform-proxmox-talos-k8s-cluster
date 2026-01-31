# Test: GPU Auto-Detection
# Verifies that GPU type is correctly detected from the gpu field name

run "test_nvidia_gpu_detection" {
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

    vms = {
      worker-nvidia-3090 = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.30"
        cpu            = 16
        ram_dedicated  = 32768
        os_disk_size   = 10
        data_disk_size = 100
        gpu            = "nvidia-3090"
      }
      worker-nvidia-uppercase = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.31"
        cpu            = 16
        ram_dedicated  = 32768
        os_disk_size   = 10
        data_disk_size = 100
        gpu            = "NVIDIA-A100"
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
      "NVIDIA-A100" = {
        name         = "NVIDIA-A100"
        id           = "10de:20f1"
        iommu_group  = 43
        node         = "pve1"
        path         = "0000:02:00.0"
        subsystem_id = "10de:1450"
      }
    }
  }

  # Test NVIDIA detection (case-insensitive)
  assert {
    condition     = local.vm_gpu_types["worker-nvidia-3090"] == "nvidia"
    error_message = "GPU type should be detected as 'nvidia' for gpu='nvidia-3090'"
  }

  assert {
    condition     = local.vm_gpu_types["worker-nvidia-uppercase"] == "nvidia"
    error_message = "GPU type should be detected as 'nvidia' for gpu='NVIDIA-A100' (case-insensitive)"
  }
}

run "test_intel_gpu_detection" {
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

    vms = {
      worker-intel-arc = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.32"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 10
        data_disk_size = 50
        gpu            = "intel-arc-a770"
      }
      worker-Intel-uppercase = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.33"
        cpu            = 8
        ram_dedicated  = 16384
        os_disk_size   = 10
        data_disk_size = 50
        gpu            = "INTEL-GPU"
      }
    }

    pci = {
      intel-arc-a770 = {
        name         = "intel-arc-a770"
        id           = "8086:56a0"
        iommu_group  = 44
        node         = "pve1"
        path         = "0000:03:00.0"
        subsystem_id = "8086:1234"
      }
      "INTEL-GPU" = {
        name         = "INTEL-GPU"
        id           = "8086:5690"
        iommu_group  = 45
        node         = "pve1"
        path         = "0000:04:00.0"
        subsystem_id = "8086:5678"
      }
    }
  }

  # Test Intel detection (case-insensitive)
  assert {
    condition     = local.vm_gpu_types["worker-intel-arc"] == "intel"
    error_message = "GPU type should be detected as 'intel' for gpu='intel-arc-a770'"
  }

  assert {
    condition     = local.vm_gpu_types["worker-Intel-uppercase"] == "intel"
    error_message = "GPU type should be detected as 'intel' for gpu='INTEL-GPU' (case-insensitive)"
  }
}

run "test_no_gpu_detection" {
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

    vms = {
      worker-standard = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.40"
        cpu            = 4
        ram_dedicated  = 8192
        os_disk_size   = 10
        data_disk_size = 20
        # No GPU
      }
    }
  }

  # Test no GPU detection
  assert {
    condition     = local.vm_gpu_types["worker-standard"] == "base"
    error_message = "GPU type should be 'base' when no GPU is configured"
  }
}

run "test_unknown_gpu_fallback" {
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

    vms = {
      worker-amd = {
        host_node      = "pve1"
        machine_type   = "worker"
        ip             = "192.168.1.41"
        cpu            = 16
        ram_dedicated  = 32768
        os_disk_size   = 10
        data_disk_size = 100
        gpu            = "amd-radeon-rx7900"
      }
    }

    pci = {
      amd-radeon-rx7900 = {
        name         = "amd-radeon-rx7900"
        id           = "1002:744c"
        iommu_group  = 46
        node         = "pve1"
        path         = "0000:05:00.0"
        subsystem_id = "1002:0e3b"
      }
    }
  }

  # Test unknown GPU fallback to base
  assert {
    condition     = local.vm_gpu_types["worker-amd"] == "base"
    error_message = "GPU type should fallback to 'base' for unknown GPU types (e.g., AMD)"
  }
}
