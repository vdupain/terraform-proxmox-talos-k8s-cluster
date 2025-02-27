<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >=3.4.5 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >=0.73.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | >=3.4.5 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >=0.73.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_hardware_mapping_pci.pci](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_hardware_mapping_pci) | resource |
| [proxmox_virtual_environment_vm.vms](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) | resource |
| [time_sleep.waiting_if_dhcp](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [http_http.schematic_id](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.schematic_nvidia_id](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration | <pre>object({<br/>    network_dhcp  = optional(bool, false)<br/>    gateway       = string<br/>    cidr          = number<br/>    vlan_id       = optional(number, null)<br/>    name          = string<br/>    talos_version = optional(string, "v1.9.0")<br/>  })</pre> | n/a | yes |
| <a name="input_pci"></a> [pci](#input\_pci) | Configuration mapping PCI | <pre>map(object({<br/>    name         = string<br/>    id           = string<br/>    iommu_group  = number<br/>    node         = string<br/>    path         = string<br/>    subsystem_id = string<br/>  }))</pre> | `null` | no |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox configuration | <pre>object({<br/>    endpoint      = string<br/>    insecure      = bool<br/>    username      = string<br/>    password      = optional(string)<br/>    api_token     = optional(string)<br/>    ssh_agent     = optional(string, false)<br/>    random_vm_ids = optional(string, false)<br/>  })</pre> | n/a | yes |
| <a name="input_vms"></a> [vms](#input\_vms) | Configuration for cluster nodes | <pre>map(object({<br/>    host_node      = string<br/>    machine_type   = string<br/>    datastore_id   = optional(string, "local-lvm")<br/>    ip             = string<br/>    cpu            = number<br/>    ram_dedicated  = number<br/>    os_disk_size   = number<br/>    data_disk_size = number<br/>    gpu            = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_ipv4_addresses"></a> [config\_ipv4\_addresses](#output\_config\_ipv4\_addresses) | IPv4 addresses |
| <a name="output_qemu_ipv4_addresses"></a> [qemu\_ipv4\_addresses](#output\_qemu\_ipv4\_addresses) | Qemu IPv4 addresses |
| <a name="output_vm_ipv4_address_vms"></a> [vm\_ipv4\_address\_vms](#output\_vm\_ipv4\_address\_vms) | IPv4 addresses |
<!-- END_TF_DOCS -->