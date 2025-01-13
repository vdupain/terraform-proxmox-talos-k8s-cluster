locals {
  first_control_plane = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster.name
  cluster_endpoint = var.cluster.network_dhcp ? "https://${local.first_control_plane}:6443" : "https://${var.cluster.endpoint}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster.name
  cluster_endpoint = var.cluster.network_dhcp ? "https://${local.first_control_plane}:6443" : "https://${var.cluster.endpoint}:6443"
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
  for_each = {
    for k, v in var.nodes : k => v
    if v.machine_type == "controlplane"
  }
  node = each.value.ip
  config_patches = [
    templatefile("${path.module}/config/control-plane.yaml.tmpl", {
      hostname       = "${var.cluster.name}-${each.key}"
      install_disk   = each.value.install_disk
      cilium_values  = file("${path.module}/kubernetes/cilium-values.yaml")
      cilium_install = file("${path.module}/kubernetes/cilium-install.yaml")
      zfs_setup      = file("${path.module}/kubernetes/zfs-setup.yaml")
    }),
    file("${path.module}/config/falco-patch.yaml"),
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each = {
    for k, v in var.nodes : k => v
    if v.machine_type == "worker"
  }
  node = each.value.ip
  config_patches = [
    templatefile("${path.module}/config/worker.yaml.tmpl", {
      hostname     = "${var.cluster.name}-${each.key}"
      install_disk = each.value.install_disk
    }),
  ]
}

resource "talos_machine_configuration_apply" "worker_gpu" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each = {
    for k, v in var.nodes : k => v
    if v.machine_type == "worker" && v.gpu != null
  }
  node = each.value.ip
  config_patches = [
    templatefile("${path.module}/config/worker.yaml.tmpl", {
      hostname     = "${var.cluster.name}-${each.key}"
      install_disk = each.value.install_disk
    }),
    file("${path.module}/config/gpu-worker-patch.yaml"),
    file("${path.module}/config/nvidia-default-runtimeclass.yaml"),
  ]
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
