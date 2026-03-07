# Tests for the vms_proxmox module.
# Covers: VM naming convention, VM count, DHCP vs static IP, PCI mapping.
# Run from modules/vms_proxmox/: tofu test

mock_provider "proxmox" {
  mock_resource "proxmox_virtual_environment_vm" {
    defaults = {
      ipv4_addresses = [["192.168.1.10"]]
      mac_addresses  = ["AA:BB:CC:DD:EE:FF"]
      network_device = [{ mac_address = "AA:BB:CC:DD:EE:FF" }]
    }
  }
  mock_resource "proxmox_virtual_environment_download_file" {
    defaults = {
      id = "local:iso/test.img"
    }
  }
  mock_resource "proxmox_virtual_environment_hardware_mapping_pci" {}
}

mock_provider "http" {
  mock_data "http" {
    defaults = {
      response_body = "{\"id\":\"abc123schematicid\"}"
    }
  }
}

mock_provider "time" {
  mock_resource "time_sleep" {}
}

# File-level variable defaults shared across all run blocks
variables {
  proxmox = {
    endpoint  = "https://pve.test:8006"
    insecure  = true
    username  = "root@pam"
    api_token = "root@pam!test=secret"
  }
  cluster = {
    name          = "my-cluster"
    gateway       = "192.168.1.1"
    cidr          = 24
    talos_version = "v1.12.4"
  }
  vms = {
    "cp-0" = {
      host_node        = "pve1"
      machine_type     = "controlplane"
      ip               = "192.168.1.10"
      cpu              = 2
      memory_dedicated = 4096
      system_disk_size = 10
      user_disk_size   = 20
    }
  }
}

# ── VM naming ────────────────────────────────────────────────────────────────

# VMs must be named {cluster.name}-{vm_key} and placed on the correct host node.
run "vm_naming_follows_convention" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.vms["cp-0"].name == "my-cluster-cp-0"
    error_message = "VM name should be '{cluster.name}-{vm_key}'"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.vms["cp-0"].node_name == "pve1"
    error_message = "VM should be placed on the host node specified in the vm config"
  }
}

# Tags must include terraform, talos, k8s, the machine type, and the cluster name.
run "vm_tags_are_set" {
  command = plan

  assert {
    condition     = contains(proxmox_virtual_environment_vm.vms["cp-0"].tags, "terraform")
    error_message = "VM should have 'terraform' tag"
  }

  assert {
    condition     = contains(proxmox_virtual_environment_vm.vms["cp-0"].tags, "my-cluster")
    error_message = "VM should have the cluster name as a tag"
  }

  assert {
    condition     = contains(proxmox_virtual_environment_vm.vms["cp-0"].tags, "controlplane")
    error_message = "VM should have its machine_type as a tag"
  }
}

# ── VM count ─────────────────────────────────────────────────────────────────

# One proxmox_virtual_environment_vm resource is created per entry in var.vms.
run "vm_count_matches_input" {
  command = plan

  variables {
    vms = {
      "cp-0" = {
        host_node        = "pve1"
        machine_type     = "controlplane"
        ip               = "192.168.1.10"
        cpu              = 2
        memory_dedicated = 4096
        system_disk_size = 10
        user_disk_size   = 20
      }
      "cp-1" = {
        host_node        = "pve1"
        machine_type     = "controlplane"
        ip               = "192.168.1.11"
        cpu              = 2
        memory_dedicated = 4096
        system_disk_size = 10
        user_disk_size   = 20
      }
      "worker-0" = {
        host_node        = "pve1"
        machine_type     = "worker"
        ip               = "192.168.1.20"
        cpu              = 4
        memory_dedicated = 8192
        system_disk_size = 20
        user_disk_size   = 50
      }
    }
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.vms) == 3
    error_message = "Should create exactly one VM per entry in var.vms"
  }
}

# ── Static vs DHCP networking ────────────────────────────────────────────────

# In static mode the IP is set to {ip}/{cidr} and gateway is configured.
run "static_networking_uses_configured_ip" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.vms["cp-0"].initialization[0].ip_config[0].ipv4[0].address == "192.168.1.10/24"
    error_message = "Static mode should set IP to '{ip}/{cidr}'"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.vms["cp-0"].initialization[0].ip_config[0].ipv4[0].gateway == "192.168.1.1"
    error_message = "Static mode should set the gateway"
  }
}

# In DHCP mode the IP is set to the literal string "dhcp".
run "dhcp_networking_sets_address_to_dhcp" {
  command = plan

  variables {
    cluster = {
      name          = "my-cluster"
      network_dhcp  = true
      gateway       = "192.168.1.1"
      cidr          = 24
      talos_version = "v1.12.4"
    }
  }

  assert {
    condition     = proxmox_virtual_environment_vm.vms["cp-0"].initialization[0].ip_config[0].ipv4[0].address == "dhcp"
    error_message = "DHCP mode should set IP address to the literal string 'dhcp'"
  }
}

# ── PCI / GPU passthrough ────────────────────────────────────────────────────

# When pci is null, no hardware mapping resources are created.
run "no_pci_mapping_when_pci_is_null" {
  command = plan

  assert {
    condition     = length(proxmox_virtual_environment_hardware_mapping_pci.pci) == 0
    error_message = "No PCI mapping resources should be created when pci input is null"
  }
}

# When pci entries are provided, one mapping resource is created per entry.
run "pci_mappings_created_per_entry" {
  command = plan

  variables {
    pci = {
      "gpu-0" = {
        name             = "nvidia-rtx4090"
        id               = "10de:2204"
        iommu_group      = 14
        node             = "pve1"
        path             = "0000:03:00.0"
        subsystem_id     = "10de:0000"
        mediated_devices = false
      }
    }
  }

  assert {
    condition     = length(proxmox_virtual_environment_hardware_mapping_pci.pci) == 1
    error_message = "One PCI mapping resource should be created per pci entry"
  }

  assert {
    condition     = proxmox_virtual_environment_hardware_mapping_pci.pci["gpu-0"].name == "nvidia-rtx4090"
    error_message = "PCI mapping name should match the configured name"
  }
}
