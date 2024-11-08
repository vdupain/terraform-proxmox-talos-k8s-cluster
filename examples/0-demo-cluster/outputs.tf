output "cluster_name" {
  value     = module.talos_k8s_cluster.cluster_name
  sensitive = false
}

output "config_ipv4_addresses" {
  value = module.talos_k8s_cluster.config_ipv4_addresses
}
