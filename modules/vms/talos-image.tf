locals {
  factory_url = "https://factory.talos.dev"
  platform    = "nocloud"
  arch        = "amd64"
  version     = "v1.8.2"

  schematic    = file("${path.module}/schematic.yaml")
  schematic_id = jsondecode(data.http.schematic_id.response_body)["id"]
  image_id     = "${local.schematic_id}_${local.version}"

  schematic_nvidia    = file("${path.module}/schematic-nvidia.yaml")
  schematic_nvidia_id = jsondecode(data.http.schematic_nvidia_id.response_body)["id"]
  image_nvidia_id     = "${local.schematic_nvidia_id}_${local.version}"
}

data "http" "schematic_id" {
  url          = "${local.factory_url}/schematics"
  method       = "POST"
  request_body = local.schematic
}

data "http" "schematic_nvidia_id" {
  url          = "${local.factory_url}/schematics"
  method       = "POST"
  request_body = local.schematic_nvidia
}

resource "proxmox_virtual_environment_download_file" "this" {
  for_each = toset(distinct([for k, v in var.vms : "${v.host_node}_${v.gpu == true ? local.image_nvidia_id : local.image_id}"]))

  node_name    = split("_", each.key)[0]
  content_type = "iso"
  datastore_id = "local"

  file_name               = "${var.cluster.name}-talos-${split("_", each.key)[1]}-${split("_", each.key)[2]}-${local.platform}-${local.arch}.img"
  url                     = "${local.factory_url}/image/${split("_", each.key)[1]}/${split("_", each.key)[2]}/${local.platform}-${local.arch}.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}
