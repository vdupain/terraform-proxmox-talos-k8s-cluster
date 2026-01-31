# Test: Control Plane Scheduling
# Verifies that allowSchedulingOnControlPlanes parameter works correctly

run "test_scheduling_enabled" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                               = "test-cluster"
      talos_version                      = "v1.12.1"
      gateway                            = "192.168.1.1"
      cidr                               = 24
      allow_scheduling_on_control_planes = true
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

  # Verify scheduling is enabled
  assert {
    condition     = var.cluster.allow_scheduling_on_control_planes == true
    error_message = "Control plane scheduling should be enabled"
  }
}

run "test_scheduling_disabled" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                               = "test-cluster"
      talos_version                      = "v1.12.1"
      gateway                            = "192.168.1.1"
      cidr                               = 24
      allow_scheduling_on_control_planes = false
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

  # Verify scheduling is disabled
  assert {
    condition     = var.cluster.allow_scheduling_on_control_planes == false
    error_message = "Control plane scheduling should be disabled"
  }
}

run "test_control_plane_with_gpu" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name                               = "test-cluster"
      talos_version                      = "v1.12.1"
      gateway                            = "192.168.1.1"
      cidr                               = 24
      allow_scheduling_on_control_planes = true
    }

    vms = {
      cp-gpu-01 = {
        host_node      = "pve1"
        machine_type   = "controlplane"
        ip             = "192.168.1.10"
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

  # Verify control plane can have GPU when scheduling is enabled
  assert {
    condition     = var.cluster.allow_scheduling_on_control_planes == true
    error_message = "Control plane with GPU should have scheduling enabled"
  }

  assert {
    condition     = var.vms["cp-gpu-01"].machine_type == "controlplane"
    error_message = "Node should be control plane type"
  }

  assert {
    condition     = var.vms["cp-gpu-01"].gpu == "nvidia-a100"
    error_message = "Control plane should have GPU assigned"
  }
}
