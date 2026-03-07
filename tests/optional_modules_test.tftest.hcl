# Tests for optional module instantiation at the root level.
# gitops_k8s and init_k8s use count = 0/1 based on whether their input variables are null.
# Run from repo root: tofu test tests/optional_modules_test.tftest.hcl

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

mock_provider "talos" {
  mock_resource "talos_machine_secrets" {
    defaults = {
      machine_secrets = {}
      client_configuration = {
        ca_certificate     = "dGVzdC1jYQ=="
        client_certificate = "dGVzdC1jZXJ0"
        client_key         = "dGVzdC1rZXk="
      }
    }
  }
  mock_resource "talos_machine_configuration_apply" {}
  mock_resource "talos_machine_bootstrap" {}
  mock_resource "talos_cluster_kubeconfig" {
    defaults = {
      kubeconfig_raw = "test-kubeconfig"
      kubernetes_client_configuration = {
        host               = "https://192.168.1.10:6443"
        client_certificate = "dGVzdC1jZXJ0"
        client_key         = "dGVzdC1rZXk="
        ca_certificate     = "dGVzdC1jYQ=="
      }
    }
  }
  mock_data "talos_machine_configuration" {
    defaults = {
      machine_configuration = "test-machine-config"
    }
  }
  mock_data "talos_client_configuration" {
    defaults = {
      talos_config = "test-talos-config"
      client_configuration = {
        ca_certificate     = "dGVzdC1jYQ=="
        client_certificate = "dGVzdC1jZXJ0"
        client_key         = "dGVzdC1rZXk="
      }
    }
  }
  mock_data "talos_cluster_health" {}
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

mock_provider "local" {
  mock_resource "local_file" {}
}

mock_provider "kubernetes" {}

mock_provider "flux" {
  mock_resource "flux_bootstrap_git" {}
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
    name     = "test"
    gateway  = "192.168.1.1"
    cidr     = 24
    endpoint = "192.168.1.10"
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
  gitops      = null
  certificate = null
}

# When both optional inputs are null, neither optional module is instantiated.
run "optional_modules_skipped_when_null" {
  command = plan

  assert {
    condition     = length(module.gitops_k8s) == 0
    error_message = "gitops_k8s module should not be instantiated when gitops is null"
  }

  assert {
    condition     = length(module.init_k8s) == 0
    error_message = "init_k8s module should not be instantiated when certificate is null"
  }
}

# When gitops is configured, the gitops_k8s module is instantiated.
run "gitops_module_created_when_configured" {
  command = plan

  variables {
    gitops = {
      repository   = "https://github.com/test/gitops.git"
      token        = "test-token"
      cluster_name = "test"
    }
    certificate = null
  }

  assert {
    condition     = length(module.gitops_k8s) == 1
    error_message = "gitops_k8s module should be instantiated when gitops is configured"
  }

  assert {
    condition     = length(module.init_k8s) == 0
    error_message = "init_k8s module should not be instantiated when certificate is null"
  }
}

# When certificate is provided, the init_k8s module is instantiated.
run "init_k8s_created_when_certificate_provided" {
  command = plan

  variables {
    gitops = null
    certificate = {
      cert = "test-cert-content"
      key  = "test-key-content"
    }
  }

  assert {
    condition     = length(module.init_k8s) == 1
    error_message = "init_k8s module should be instantiated when certificate is provided"
  }

  assert {
    condition     = length(module.gitops_k8s) == 0
    error_message = "gitops_k8s module should not be instantiated when gitops is null"
  }
}

# The cluster_name output always reflects the input cluster name.
run "cluster_name_output_matches_input" {
  command = plan

  assert {
    condition     = output.cluster_name == "test"
    error_message = "cluster_name output should match var.cluster.name"
  }
}
