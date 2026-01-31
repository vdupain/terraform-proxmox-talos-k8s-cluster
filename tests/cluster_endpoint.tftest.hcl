# Test: Cluster Endpoint Logic
# Verifies that cluster endpoint is determined correctly with priority:
# 1. VIP if configured (for HA control plane with virtual IP)
# 2. Explicit endpoint if provided
# 3. First control plane IP (default/fallback)

run "test_endpoint_with_vip_configured" {
  command = plan

  module {
    source = "./modules/talos_k8s"
  }

  variables {
    cluster = {
      name                               = "test-vip-cluster"
      vip_ip                             = "192.168.1.100"
      vip_interface                      = "eth0"
      endpoint                           = "192.168.1.200"
      allow_scheduling_on_control_planes = true
    }

    nodes = {
      cp-01 = {
        machine_type = "controlplane"
        ip           = "192.168.1.10"
        install_disk = "/dev/sda"
      }
      cp-02 = {
        machine_type = "controlplane"
        ip           = "192.168.1.11"
        install_disk = "/dev/sda"
      }
    }
  }

  # VIP should take priority over explicit endpoint
  assert {
    condition     = local.cluster_endpoint == "192.168.1.100"
    error_message = "Cluster endpoint should be VIP when VIP is configured (priority 1)"
  }

  assert {
    condition     = data.talos_machine_configuration.controlplane.cluster_endpoint == "https://192.168.1.100:6443"
    error_message = "Control plane config should use VIP as cluster endpoint"
  }
}

run "test_endpoint_explicit_without_vip" {
  command = plan

  module {
    source = "./modules/talos_k8s"
  }

  variables {
    cluster = {
      name                               = "test-explicit-endpoint"
      endpoint                           = "192.168.1.200"
      allow_scheduling_on_control_planes = true
    }

    nodes = {
      cp-01 = {
        machine_type = "controlplane"
        ip           = "192.168.1.10"
        install_disk = "/dev/sda"
      }
      cp-02 = {
        machine_type = "controlplane"
        ip           = "192.168.1.11"
        install_disk = "/dev/sda"
      }
    }
  }

  # Explicit endpoint should be used when VIP is not configured
  assert {
    condition     = local.cluster_endpoint == "192.168.1.200"
    error_message = "Cluster endpoint should be explicit endpoint when VIP is not configured (priority 2)"
  }

  assert {
    condition     = data.talos_machine_configuration.controlplane.cluster_endpoint == "https://192.168.1.200:6443"
    error_message = "Control plane config should use explicit endpoint"
  }
}

run "test_endpoint_default_first_control_plane" {
  command = plan

  module {
    source = "./modules/talos_k8s"
  }

  variables {
    cluster = {
      name                               = "test-default-endpoint"
      allow_scheduling_on_control_planes = true
    }

    nodes = {
      cp-01 = {
        machine_type = "controlplane"
        ip           = "192.168.1.10"
        install_disk = "/dev/sda"
      }
      cp-02 = {
        machine_type = "controlplane"
        ip           = "192.168.1.11"
        install_disk = "/dev/sda"
      }
      worker-01 = {
        machine_type = "worker"
        ip           = "192.168.1.20"
        install_disk = "/dev/sda"
      }
    }
  }

  # First control plane IP should be used as default
  assert {
    condition     = local.cluster_endpoint == "192.168.1.10"
    error_message = "Cluster endpoint should default to first control plane IP (priority 3)"
  }

  assert {
    condition     = data.talos_machine_configuration.controlplane.cluster_endpoint == "https://192.168.1.10:6443"
    error_message = "Control plane config should use first control plane IP as default"
  }
}

run "test_endpoint_dhcp_mode" {
  command = plan

  module {
    source = "./modules/talos_k8s"
  }

  variables {
    cluster = {
      name                               = "test-dhcp-cluster"
      network_dhcp                       = true
      allow_scheduling_on_control_planes = true
    }

    nodes = {
      cp-01 = {
        machine_type = "controlplane"
        ip           = "192.168.1.10"
        install_disk = "/dev/sda"
      }
    }
  }

  # In DHCP mode, should use first control plane IP
  assert {
    condition     = local.cluster_endpoint == "192.168.1.10"
    error_message = "Cluster endpoint should be first control plane IP in DHCP mode"
  }
}

run "test_endpoint_vip_overrides_dhcp" {
  command = plan

  module {
    source = "./modules/talos_k8s"
  }

  variables {
    cluster = {
      name                               = "test-vip-dhcp-cluster"
      network_dhcp                       = true
      vip_ip                             = "192.168.1.100"
      vip_interface                      = "eth0"
      allow_scheduling_on_control_planes = true
    }

    nodes = {
      cp-01 = {
        machine_type = "controlplane"
        ip           = "192.168.1.10"
        install_disk = "/dev/sda"
      }
      cp-02 = {
        machine_type = "controlplane"
        ip           = "192.168.1.11"
        install_disk = "/dev/sda"
      }
    }
  }

  # VIP should take priority even in DHCP mode
  assert {
    condition     = local.cluster_endpoint == "192.168.1.100"
    error_message = "VIP should override DHCP mode for cluster endpoint"
  }
}

run "test_endpoint_consistency_across_configs" {
  command = plan

  module {
    source = "./modules/talos_k8s"
  }

  variables {
    cluster = {
      name                               = "test-consistency"
      vip_ip                             = "192.168.1.100"
      vip_interface                      = "eth0"
      allow_scheduling_on_control_planes = false
    }

    nodes = {
      cp-01 = {
        machine_type = "controlplane"
        ip           = "192.168.1.10"
        install_disk = "/dev/sda"
      }
      worker-01 = {
        machine_type = "worker"
        ip           = "192.168.1.20"
        install_disk = "/dev/sda"
      }
    }
  }

  # Both control plane and worker configs should use same endpoint
  assert {
    condition     = data.talos_machine_configuration.controlplane.cluster_endpoint == data.talos_machine_configuration.worker.cluster_endpoint
    error_message = "Control plane and worker configs must use the same cluster endpoint"
  }

  assert {
    condition     = data.talos_machine_configuration.controlplane.cluster_endpoint == "https://192.168.1.100:6443"
    error_message = "Both configs should use VIP endpoint"
  }
}
