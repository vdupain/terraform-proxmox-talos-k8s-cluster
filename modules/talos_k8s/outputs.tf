output "talos_config" {
  description = "Talos configuration file"
  value       = data.talos_client_configuration.this
  sensitive   = true
}

output "kube_config" {
  description = "Kubernetes configuration file"
  value       = talos_cluster_kubeconfig.this
  sensitive   = true
}