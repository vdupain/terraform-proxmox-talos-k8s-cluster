output "vm_ipv4_address_vms" {
  value = [
    for vm in proxmox_virtual_environment_vm.vms : vm.initialization[0].ip_config[0].ipv4[0].address
  ]
}

output "config_ipv4_addresses" {
  value = {
    for vm in proxmox_virtual_environment_vm.vms : vm.name => vm.initialization[0].ip_config[0].ipv4[0].address
  }
}
