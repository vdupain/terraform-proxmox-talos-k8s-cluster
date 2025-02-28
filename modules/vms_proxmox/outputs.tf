output "vm_ipv4_address_vms" {
  description = "IPv4 addresses"
  value = [
    for vm in proxmox_virtual_environment_vm.vms : vm.initialization[0].ip_config[0].ipv4[0].address
  ]
}

output "config_ipv4_addresses" {
  description = "IPv4 addresses"
  value = {
    for vm in proxmox_virtual_environment_vm.vms : vm.name
    => vm.initialization[0].ip_config[0].ipv4[0].address
  }
}

output "qemu_ipv4_addresses" {
  description = "Qemu IPv4 addresses"
  depends_on  = [time_sleep.waiting_if_dhcp]
  value = {
    for vm in proxmox_virtual_environment_vm.vms : trimprefix(vm.name, "${var.cluster.name}-")
    => element(vm.ipv4_addresses, index(vm.mac_addresses, vm.network_device[0].mac_address))[0]
  }
}