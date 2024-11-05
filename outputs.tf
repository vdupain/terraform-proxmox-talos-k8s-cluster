output "vm_ipv4_address_vms" {
  description = "Retrieves IPv4 address for a k8s Talos cluster"
  value       = module.vms.vm_ipv4_address_vms
}

output "config_ipv4_addresses" {
  description = "Retrieves VM names with IPv4 address for a k8s Talos cluster"
  value       = module.vms.config_ipv4_addresses
}

output "qemu_ipv4_addresses" {
  description = "Retrieves VM names with IPv4 address for a k8s Talos cluster"
  value       = module.vms.qemu_ipv4_addresses
}

output "kube_config" {
  description = "Retrieves the kubeconfig for a k8s Talos cluster"
  value       = module.talos_k8s.kube_config.kubeconfig_raw
  sensitive   = true
}

output "talos_config" {
  description = "Retrieves the talosconfig for a k8s Talos cluster"
  value       = module.talos_k8s.talos_config.talos_config
  sensitive   = true
}

resource "local_file" "talos_config" {
  content         = module.talos_k8s.talos_config.talos_config
  filename        = "output/talos-config.yaml"
  file_permission = "0600"
}

resource "local_file" "kube_config" {
  content         = module.talos_k8s.kube_config.kubeconfig_raw
  filename        = "output/kube-config.yaml"
  file_permission = "0600"
}

output "cluster_name" {
  description = "Retrieves the name for a k8s Talos cluster"
  value       = var.cluster.name
  sensitive   = false
}
