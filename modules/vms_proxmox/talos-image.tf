locals {
  factory_url = "https://factory.talos.dev"
  platform    = "nocloud"
  arch        = "amd64"
  version     = var.cluster.talos_version

  # Load schematic templates
  schematic_templates = {
    base   = yamldecode(file("${path.module}/schematics/base.yaml"))
    nvidia = yamldecode(file("${path.module}/schematics/nvidia.yaml"))
  }

  # Detect GPU type for each VM
  vm_gpu_types = {
    for k, v in var.vms : k => (
      v.gpu == null ? "base" : (
        can(regex("(?i)nvidia", v.gpu)) ? "nvidia" : "base"
      )
    )
  }

  # Unique GPU types actually used
  used_gpu_types = toset(values(local.vm_gpu_types))

  # Build merged extension lists for each GPU type
  # Base extensions + GPU-specific extensions + additional extensions
  extensions_by_type = {
    for gpu_type in ["base", "nvidia"] : gpu_type => concat(
      # Base extensions (always included)
      local.schematic_templates.base.customization.systemExtensions.officialExtensions,
      # GPU-specific extensions (if not base)
      gpu_type != "base" ? local.schematic_templates[gpu_type].customization.systemExtensions.officialExtensions : [],
      # Additional user-provided extensions
      var.additional_extensions
    )
  }

  # Generate schematics for each used GPU type
  schematics = {
    for gpu_type in local.used_gpu_types : gpu_type => yamlencode({
      customization = {
        systemExtensions = {
          officialExtensions = local.extensions_by_type[gpu_type]
        }
      }
    })
  }

  # Schematic IDs for each GPU type
  schematic_ids = {
    for gpu_type in local.used_gpu_types : gpu_type => jsondecode(data.http.schematic[gpu_type].response_body)["id"]
  }

  # Image IDs for each GPU type
  image_ids = {
    for gpu_type in local.used_gpu_types : gpu_type => "${local.schematic_ids[gpu_type]}_${local.version}"
  }
}

data "http" "schematic" {
  for_each = local.schematics

  url          = "${local.factory_url}/schematics"
  method       = "POST"
  request_body = each.value
}

resource "proxmox_download_file" "this" {
  for_each = toset(distinct([for k, v in var.vms : "${v.host_node}_${local.image_ids[local.vm_gpu_types[k]]}"]))

  node_name    = split("_", each.key)[0]
  content_type = "iso"
  datastore_id = "local"

  file_name               = "${var.cluster.name}-talos-${split("_", each.key)[1]}-${split("_", each.key)[2]}-${local.platform}-${local.arch}.img"
  url                     = "${local.factory_url}/image/${split("_", each.key)[1]}/${split("_", each.key)[2]}/${local.platform}-${local.arch}.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
  overwrite_unmanaged     = true
}