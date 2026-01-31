# Test: Default Values
# Verifies that all new parameters have correct default values

run "test_default_cluster_parameters" {
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

  # Test default values
  assert {
    condition     = var.cluster.allow_scheduling_on_control_planes == true
    error_message = "Default allow_scheduling_on_control_planes should be true"
  }

  assert {
    condition     = var.cluster.vip_ip == null
    error_message = "Default vip_ip should be null"
  }

  assert {
    condition     = var.cluster.vip_interface == "eth0"
    error_message = "Default vip_interface should be 'eth0'"
  }

  assert {
    condition     = length(var.additional_extensions) == 0
    error_message = "Default additional_extensions should be empty"
  }
}
