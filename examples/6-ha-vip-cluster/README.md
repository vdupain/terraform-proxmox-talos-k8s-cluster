<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_talos_k8s_cluster"></a> [talos\_k8s\_cluster](#module\_talos\_k8s\_cluster) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate"></a> [certificate](#input\_certificate) | Certificate for k8s sealed-secrets (optional) | <pre>object({<br/>    cert = string<br/>    key  = string<br/>  })</pre> | `null` | no |
| <a name="input_gitops"></a> [gitops](#input\_gitops) | GitOps configuration (optional) | <pre>object({<br/>    repository   = string<br/>    token        = string<br/>    cluster_name = string<br/>  })</pre> | `null` | no |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox configuration | <pre>object({<br/>    endpoint  = string<br/>    insecure  = bool<br/>    username  = string<br/>    password  = optional(string)<br/>    api_token = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_instructions"></a> [access\_instructions](#output\_access\_instructions) | Instructions for accessing the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Kubernetes API endpoint (VIP) |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the Kubernetes cluster |
| <a name="output_control_plane_ips"></a> [control\_plane\_ips](#output\_control\_plane\_ips) | IP addresses of control plane nodes |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Path to kubeconfig file |
| <a name="output_talosconfig_path"></a> [talosconfig\_path](#output\_talosconfig\_path) | Path to talosconfig file |
| <a name="output_vip_address"></a> [vip\_address](#output\_vip\_address) | Virtual IP address for HA control plane |
| <a name="output_worker_ips"></a> [worker\_ips](#output\_worker\_ips) | IP addresses of worker nodes |
<!-- END_TF_DOCS -->