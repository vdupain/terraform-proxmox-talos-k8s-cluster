<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_talos-k8s-cluster"></a> [talos-k8s-cluster](#module\_talos-k8s-cluster) | vdupain/talos-k8s-cluster/proxmox | 1.0.0-rc3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | n/a | <pre>object({<br/>    endpoint  = string<br/>    insecure  = bool<br/>    username  = string<br/>    password  = string<br/>    api_token = string<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->