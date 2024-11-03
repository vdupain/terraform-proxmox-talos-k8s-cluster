output "cluster_name" {
  value     = module.talos-k8s-cluster.cluster_name
  sensitive = false
}

output "config_ipv4_addresses" {
  value = module.talos-k8s-cluster.config_ipv4_addresses
}
