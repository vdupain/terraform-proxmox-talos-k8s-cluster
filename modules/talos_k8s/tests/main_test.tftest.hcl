# Tests for the talos_k8s module.
# Covers: cluster endpoint priority, node type segregation, GPU config patch injection.
# Run from modules/talos_k8s/: tofu test

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

# ── Endpoint priority ────────────────────────────────────────────────────────

# Priority 1: VIP takes precedence over all other options.
run "endpoint_uses_vip_when_set" {
  command = plan

  variables {
    cluster = {
      name          = "test"
      endpoint      = "192.168.1.10"
      vip_ip        = "192.168.1.100"
      vip_interface = "eth0"
    }
    nodes = {
      "cp-0" = { machine_type = "controlplane", ip = "192.168.1.10" }
    }
  }

  assert {
    condition     = data.talos_machine_configuration.controlplane.cluster_endpoint == "https://192.168.1.100:6443"
    error_message = "VIP should be used as cluster endpoint when vip_ip is set"
  }
}

# Priority 2: Explicit endpoint is used when no VIP is configured.
run "endpoint_uses_explicit_endpoint_without_vip" {
  command = plan

  variables {
    cluster = {
      name     = "test"
      endpoint = "192.168.1.50"
    }
    nodes = {
      "cp-0" = { machine_type = "controlplane", ip = "192.168.1.10" }
    }
  }

  assert {
    condition     = data.talos_machine_configuration.controlplane.cluster_endpoint == "https://192.168.1.50:6443"
    error_message = "Explicit endpoint should be used when vip_ip is not set"
  }
}

# ── Node type segregation ────────────────────────────────────────────────────

# Each node is assigned to the correct apply resource based on machine_type.
run "nodes_assigned_to_correct_apply_resources" {
  command = plan

  variables {
    cluster = {
      name     = "test"
      endpoint = "192.168.1.10"
    }
    nodes = {
      "cp-0"     = { machine_type = "controlplane", ip = "192.168.1.10" }
      "cp-1"     = { machine_type = "controlplane", ip = "192.168.1.11" }
      "worker-0" = { machine_type = "worker", ip = "192.168.1.20" }
    }
  }

  assert {
    condition     = talos_machine_configuration_apply.controlplane["cp-0"].node == "192.168.1.10"
    error_message = "cp-0 should target its configured IP"
  }

  assert {
    condition     = talos_machine_configuration_apply.controlplane["cp-1"].node == "192.168.1.11"
    error_message = "cp-1 should target its configured IP"
  }

  assert {
    condition     = talos_machine_configuration_apply.worker["worker-0"].node == "192.168.1.20"
    error_message = "worker-0 should target its configured IP"
  }

  assert {
    condition     = !contains(keys(talos_machine_configuration_apply.controlplane), "worker-0")
    error_message = "Workers should not appear in controlplane apply resources"
  }

  assert {
    condition     = !contains(keys(talos_machine_configuration_apply.worker), "cp-0")
    error_message = "Controlplane nodes should not appear in worker apply resources"
  }
}

# Bootstrap always targets the first controlplane node.
run "bootstrap_targets_first_controlplane" {
  command = plan

  variables {
    cluster = {
      name     = "test"
      endpoint = "192.168.1.10"
    }
    nodes = {
      "cp-0"     = { machine_type = "controlplane", ip = "192.168.1.10" }
      "worker-0" = { machine_type = "worker", ip = "192.168.1.20" }
    }
  }

  assert {
    condition     = talos_machine_bootstrap.this.node == "192.168.1.10"
    error_message = "Bootstrap should target the first controlplane IP"
  }
}

# ── GPU config patch injection ───────────────────────────────────────────────

# NVIDIA GPU nodes receive an extra config patch; non-GPU nodes do not.
run "gpu_nodes_receive_nvidia_patch" {
  command = plan

  variables {
    cluster = {
      name     = "test"
      endpoint = "192.168.1.10"
    }
    nodes = {
      "cp-0"       = { machine_type = "controlplane", ip = "192.168.1.10" }
      "worker-gpu" = { machine_type = "worker", ip = "192.168.1.20", gpu = "nvidia-rtx4090" }
      "worker-cpu" = { machine_type = "worker", ip = "192.168.1.21" }
    }
  }

  assert {
    condition     = length(talos_machine_configuration_apply.worker["worker-gpu"].config_patches) == 2
    error_message = "GPU worker should have 2 config patches (base template + nvidia patch)"
  }

  assert {
    condition     = length(talos_machine_configuration_apply.worker["worker-cpu"].config_patches) == 1
    error_message = "Non-GPU worker should have 1 config patch (base template only)"
  }

  assert {
    condition     = length(talos_machine_configuration_apply.controlplane["cp-0"].config_patches) == 1
    error_message = "Non-GPU controlplane should have 1 config patch (base template only)"
  }
}

# Controlplane GPU nodes also receive the NVIDIA patch.
run "gpu_controlplane_receives_nvidia_patch" {
  command = plan

  variables {
    cluster = {
      name     = "test"
      endpoint = "192.168.1.10"
    }
    nodes = {
      "cp-gpu" = { machine_type = "controlplane", ip = "192.168.1.10", gpu = "nvidia-a100" }
    }
  }

  assert {
    condition     = length(talos_machine_configuration_apply.controlplane["cp-gpu"].config_patches) == 2
    error_message = "GPU controlplane should have 2 config patches (base template + nvidia patch)"
  }
}
