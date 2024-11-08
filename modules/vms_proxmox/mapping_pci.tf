resource "proxmox_virtual_environment_hardware_mapping_pci" "pci" {
  for_each = (var.pci == null) ? {} : var.pci
  comment  = each.value.name
  name     = each.value.name
  map = [
    {
      comment      = each.value.name
      id           = each.value.id
      iommu_group  = each.value.iommu_group
      node         = each.value.node
      path         = each.value.path
      subsystem_id = each.value.subsystem_id
    }
  ]
  mediated_devices = false
}