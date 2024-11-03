<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >=0.66.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >=0.66.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_hardware_mapping_pci.pci](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_hardware_mapping_pci) | resource |
| [proxmox_virtual_environment_vm.vms](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [http_http.schematic_id](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.schematic_nvidia_id](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration | <pre>object({<br/>    name    = string<br/>    gateway = string<br/>    cidr    = number<br/>    vlan_id = optional(number, null)<br/>  })</pre> | n/a | yes |
| <a name="input_pci"></a> [pci](#input\_pci) | Configuration mapping PCI | <pre>map(object({<br/>    name         = string<br/>    id           = string<br/>    iommu_group  = number<br/>    node         = string<br/>    path         = string<br/>    subsystem_id = string<br/>  }))</pre> | `null` | no |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox configuration | <pre>object({<br/>    endpoint  = string<br/>    insecure  = bool<br/>    username  = string<br/>    password  = optional(string)<br/>    api_token = string<br/>    ssh_agent = optional(string, false)<br/>  })</pre> | n/a | yes |
| <a name="input_vms"></a> [vms](#input\_vms) | Configuration for cluster nodes | <pre>map(object({<br/>    host_node      = string<br/>    machine_type   = string<br/>    datastore_id   = optional(string, "local-lvm")<br/>    ip             = string<br/>    cpu            = number<br/>    ram_dedicated  = number<br/>    os_disk_size   = number<br/>    data_disk_size = number<br/>    gpu            = optional(bool, false)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_ipv4_address_vms"></a> [vm\_ipv4\_address\_vms](#output\_vm\_ipv4\_address\_vms) | n/a |
<!-- END_TF_DOCS -->