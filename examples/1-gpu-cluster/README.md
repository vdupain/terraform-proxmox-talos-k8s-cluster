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
| <a name="input_gitops"></a> [gitops](#input\_gitops) | GitOps configuration | <pre>object({<br/>    repository   = string<br/>    token        = string<br/>    cluster_name = string<br/>  })</pre> | `null` | no |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox configuration | <pre>object({<br/>    endpoint  = string<br/>    insecure  = bool<br/>    username  = string<br/>    password  = string<br/>    api_token = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_config_ipv4_addresses"></a> [config\_ipv4\_addresses](#output\_config\_ipv4\_addresses) | n/a |
| <a name="output_qemu_ipv4_addresses"></a> [qemu\_ipv4\_addresses](#output\_qemu\_ipv4\_addresses) | n/a |
<!-- END_TF_DOCS -->