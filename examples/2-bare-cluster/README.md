<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_talos_k8s_cluster"></a> [talos\_k8s\_cluster](#module\_talos\_k8s\_cluster) | vdupain/talos-k8s-cluster/proxmox | 1.6.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox configuration | <pre>object({<br/>    endpoint  = string<br/>    insecure  = bool<br/>    username  = string<br/>    password  = string<br/>    api_token = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name |
| <a name="output_config_ipv4_addresses"></a> [config\_ipv4\_addresses](#output\_config\_ipv4\_addresses) | IPv4 addresses |
<!-- END_TF_DOCS -->