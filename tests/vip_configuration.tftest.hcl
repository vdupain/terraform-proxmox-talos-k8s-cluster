# Test: VIP Configuration
# Verifies that VIP (Virtual IP) is correctly configured for control plane nodes

run "test_vip_enabled" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name          = "test-cluster-vip"
      talos_version = "v1.12.1"
      gateway       = "192.168.1.1"
      cidr          = 24
      vip_ip        = "192.168.1.100"
      vip_interface = "eth1"
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
      cp-02 = {
        host_node      = "pve2"
        machine_type   = "controlplane"
        ip             = "192.168.1.11"
        cpu            = 4
        ram_dedicated  = 8192
        os_disk_size   = 10
        data_disk_size = 20
      }
    }
  }

  # Verify VIP is set
  assert {
    condition     = var.cluster.vip_ip == "192.168.1.100"
    error_message = "VIP IP should be set to 192.168.1.100"
  }

  assert {
    condition     = var.cluster.vip_interface == "eth1"
    error_message = "VIP interface should be set to eth1"
  }
}

run "test_vip_disabled" {
  command = plan

  variables {
    proxmox = {
      endpoint = "https://proxmox.example.com:8006"
      insecure = true
      username = "root@pam"
      password = "test"
    }

    cluster = {
      name          = "test-cluster-no-vip"
      talos_version = "v1.12.1"
      gateway       = "192.168.1.1"
      cidr          = 24
      # VIP not set - should use default (null)
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

  # Verify VIP is null when not configured
  assert {
    condition     = var.cluster.vip_ip == null
    error_message = "VIP should be null when not configured"
  }
}
