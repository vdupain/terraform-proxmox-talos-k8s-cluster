output "vm_ipv4_address_vms" {
  value = [
    for vm in proxmox_virtual_environment_vm.vms : vm.initialization[0].ip_config[0].ipv4[0].address
  ]
}
