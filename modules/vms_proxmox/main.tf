resource "proxmox_virtual_environment_vm" "vms" {
  for_each = var.vms

  node_name = each.value.host_node

  name    = "${var.cluster.name}-${each.key}"
  tags    = ["terraform", "talos", "k8s", each.value.machine_type, var.cluster.name]
  on_boot = true
  started = true

  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-pci"

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.ram_dedicated
  }

  network_device {
    bridge  = var.cluster.network_device_bridge
    vlan_id = var.cluster.vlan_id
  }

  # EFI disk
  efi_disk {
    datastore_id = each.value.datastore_id
    file_format  = each.value.disk_file_format
    type         = "4m"
    # pre_enrolled_keys = true
  }

  # boot disk
  disk {
    datastore_id = each.value.datastore_id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = "true"
    file_format  = each.value.disk_file_format
    size         = each.value.os_disk_size
    file_id      = proxmox_virtual_environment_download_file.this["${each.value.host_node}_${local.image_ids[local.vm_gpu_types[each.key]]}"].id
  }

  # data disk
  disk {
    datastore_id = each.value.datastore_id
    interface    = "scsi1"
    cache        = "writethrough"
    discard      = "on"
    ssd          = "true"
    file_format  = each.value.disk_file_format
    size         = each.value.data_disk_size
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = each.value.datastore_id

    dynamic "dns" {
      for_each = (var.cluster.dns_domain != null || var.cluster.dns_servers != null) ? [1] : []
      content {
        domain  = var.cluster.dns_domain
        servers = var.cluster.dns_servers
      }
    }

    ip_config {
      ipv4 {
        address = var.cluster.network_dhcp == true ? "dhcp" : "${each.value.ip}/${var.cluster.cidr}"
        gateway = var.cluster.network_dhcp == true ? null : var.cluster.gateway
      }
    }
  }

  dynamic "hostpci" {
    for_each = (each.value.gpu != null) ? [1] : []
    content {
      # Passthrough GPU
      device  = "hostpci0"
      mapping = each.value.gpu
      pcie    = true
      rombar  = true
      xvga    = false
    }
  }

  lifecycle {
    ignore_changes = [
      initialization[0].dns[0]
    ]
  }

}

resource "time_sleep" "waiting_if_dhcp" {
  depends_on      = [proxmox_virtual_environment_vm.vms]
  create_duration = (var.cluster.network_dhcp == true) ? "60s" : "0s"
}