output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = module.talos_k8s_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint (VIP)"
  value       = "https://192.168.10.200:6443"
}

output "vip_address" {
  description = "Virtual IP address for HA control plane"
  value       = "192.168.10.200"
}

output "control_plane_ips" {
  description = "IP addresses of control plane nodes"
  value = [
    "192.168.10.210",
    "192.168.10.211",
    "192.168.10.212"
  ]
}

output "worker_ips" {
  description = "IP addresses of worker nodes"
  value = [
    "192.168.10.220",
    "192.168.10.221",
    "192.168.10.222"
  ]
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = "../../output/kube-config.yaml"
}

output "talosconfig_path" {
  description = "Path to talosconfig file"
  value       = "../../output/talos-config.yaml"
}

output "access_instructions" {
  description = "Instructions for accessing the cluster"
  value       = <<-EOT

    HA Cluster with VIP deployed successfully!

    Cluster Endpoint (VIP): https://192.168.10.200:6443

    Access Kubernetes:
      kubectl --kubeconfig ../../output/kube-config.yaml get nodes

    Access Talos:
      export TALOSCONFIG="../../output/talos-config.yaml"
      talosctl config endpoint 192.168.10.210 192.168.10.211 192.168.10.212
      talosctl health

    Verify VIP:
      kubectl --kubeconfig ../../output/kube-config.yaml get pods -n kube-system | grep kube-vip
      curl -k https://192.168.10.200:6443/version

    Test Failover:
      1. Shutdown one control plane node
      2. Verify VIP fails over: kubectl get nodes
      3. Cluster remains accessible via VIP
  EOT
}