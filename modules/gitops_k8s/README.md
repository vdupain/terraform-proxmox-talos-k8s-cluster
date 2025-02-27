<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | >=1.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_flux"></a> [flux](#provider\_flux) | >=1.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [flux_bootstrap_git.this](https://registry.terraform.io/providers/fluxcd/flux/latest/docs/resources/bootstrap_git) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gitops"></a> [gitops](#input\_gitops) | GitOps configuration | <pre>object({<br/>    repository   = string<br/>    token        = string<br/>    cluster_name = string<br/>  })</pre> | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->