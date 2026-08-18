locals {
  first_control_plane = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]

  # Determine cluster endpoint with priority:
  # 1. VIP if configured (for HA control plane with virtual IP)
  # 2. Explicit endpoint if provided
  # 3. First control plane IP (for DHCP or when endpoint not specified)
  cluster_endpoint = (
    var.cluster.vip_ip != null ? var.cluster.vip_ip :
    var.cluster.endpoint != null ? var.cluster.endpoint :
    local.first_control_plane
  )

  # Detect GPU type for each node (same logic as in vms_proxmox module)
  node_gpu_types = {
    for k, v in var.nodes : k => (
      v.gpu == null ? "none" : (
        can(regex("(?i)nvidia", v.gpu)) ? "nvidia" : "none"
      )
    )
  }

  # GPU patch file paths by type
  gpu_patch_files = {
    nvidia = "${path.module}/config/gpu-nvidia-patch.yaml"
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${local.cluster_endpoint}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${local.cluster_endpoint}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
  nodes                = [for k, v in var.nodes : v.ip if v.machine_type == "worker"]
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  apply_mode                  = "auto"
  for_each = {
    for k, v in var.nodes : k => v
    if v.machine_type == "controlplane"
  }
  node = each.value.ip
  config_patches = concat(
    [
      templatefile("${path.module}/config/control-plane.yaml.tmpl", {
        install_disk                       = each.value.install_disk
        allow_scheduling_on_control_planes = var.cluster.allow_scheduling_on_control_planes
        vip_ip                             = var.cluster.vip_ip
        vip_interface                      = var.cluster.vip_interface
        cilium_values                      = file("${path.module}/kubernetes/cilium-values.yaml")
        cilium_install                     = file("${path.module}/kubernetes/cilium-install.yaml")
        gateway_api_crds                   = file("${path.module}/kubernetes/gateway-api-crds.yaml")
        zfs_setup                          = file("${path.module}/kubernetes/zfs-setup.yaml")
      }),
    ],
    # Add GPU patch if this control plane node has a GPU
    local.node_gpu_types[each.key] != "none" ? [
      file(local.gpu_patch_files[local.node_gpu_types[each.key]])
    ] : []
  )
}

resource "talos_machine_configuration_apply" "worker" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  apply_mode                  = "auto"
  for_each = {
    for k, v in var.nodes : k => v
    if v.machine_type == "worker"
  }
  node = each.value.ip
  config_patches = concat(
    [
      templatefile("${path.module}/config/worker.yaml.tmpl", {
        install_disk = each.value.install_disk
      }),
    ],
    # Add GPU patch if this worker node has a GPU
    local.node_gpu_types[each.key] != "none" ? [
      file(local.gpu_patch_files[local.node_gpu_types[each.key]])
    ] : []
  )
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
}

# tflint-ignore: terraform_unused_declarations
data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker,
    talos_machine_bootstrap.this
  ]
  client_configuration   = data.talos_client_configuration.this.client_configuration
  control_plane_nodes    = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
  worker_nodes           = [for k, v in var.nodes : v.ip if v.machine_type == "worker"]
  endpoints              = data.talos_client_configuration.this.endpoints
  skip_kubernetes_checks = true

  timeouts = {
    read = "10m"
  }
}
