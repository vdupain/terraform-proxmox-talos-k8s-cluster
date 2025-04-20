resource "proxmox_virtual_environment_hardware_mapping_usb" "usb" {
  for_each = (var.usb == null) ? {} : var.usb
  comment  = each.value.name
  name     = each.value.name
  map = [
    {
      comment      = each.value.name
      id           = each.value.id
      node         = each.value.node
      path         = each.value.path
    }
  ]
}