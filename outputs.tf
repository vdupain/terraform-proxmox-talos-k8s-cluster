output "vm_ipv4_address_vms" {
  value = [
    for vm in module.vms.vm_ipv4_address_vms : vm
  ]
}

output "kube_config" {
  value     = module.talos_k8s.kube_config.kubeconfig_raw
  sensitive = true
}

output "talos_config" {
  value     = module.talos_k8s.talos_config.talos_config
  sensitive = true
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
  value     = var.cluster.name
  sensitive = false
}
