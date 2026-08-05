output "cluster_name" {
  description = "Cluster name"
  value       = module.talos_k8s_cluster.cluster_name
  sensitive   = false
}

output "config_ipv4_addresses" {
  description = "IPv4 addresses"
  value       = module.talos_k8s_cluster.config_ipv4_addresses
}

output "qemu_ipv4_addresses" {
  description = "Qemu IPv4 addresses"
  value       = module.talos_k8s_cluster.qemu_ipv4_addresses
}

output "kube_config" {
  description = "Kubeconfig for the ai-cluster"
  value       = module.talos_k8s_cluster.kube_config.kubeconfig_raw
  sensitive   = true
}

output "talos_config" {
  description = "Talosconfig for the ai-cluster"
  value       = module.talos_k8s_cluster.talos_config.talos_config
  sensitive   = true
}
