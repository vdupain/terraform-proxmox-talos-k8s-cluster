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
  description = "Qemu IPv4 addresses (excludes loopback)"
  depends_on  = [time_sleep.waiting_if_dhcp]
  value = {
    for vm in proxmox_virtual_environment_vm.vms : trimprefix(vm.name, "${var.cluster.name}-")
    => try(
      # Use network_interface_names to find the first non-loopback interface with an IP
      [for i, name in vm.network_interface_names : vm.ipv4_addresses[i][0] if !startswith(name, "lo") && length(vm.ipv4_addresses[i]) > 0][0],
      # Fallback: flatten all IPs and pick the first non-127.0.0.1
      [for addr in flatten(vm.ipv4_addresses) : addr if !startswith(addr, "127.")][0],
      # Last resort: original mac_addresses-based lookup
      element(vm.ipv4_addresses, index(vm.mac_addresses, vm.mac_addresses[0]))[0]
    )
  }
}