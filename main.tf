module "vms" {
  source = "./modules/vms"

  proxmox = var.proxmox

  cluster = {
    name          = var.cluster.name
    gateway       = var.cluster.gateway
    cidr          = var.cluster.cidr
    vlan_id       = var.cluster.vlan_id
    talos_version = var.cluster.talos_version
    network_dhcp  = var.cluster.network_dhcp
  }

  vms = var.vms
  pci = var.pci
}

module "talos_k8s" {
  depends_on = [module.vms]
  source     = "./modules/talos_k8s"

  cluster = {
    name         = var.cluster.name
    endpoint     = var.cluster.endpoint
    network_dhcp = var.cluster.network_dhcp
  }

  nodes = { for k, vm in var.vms : k => merge(vm, {
    ip = lookup(module.vms.qemu_ipv4_addresses, k, vm.ip)
  }) }


}
module "sealed-secrets" {
  depends_on = [module.talos_k8s]
  source     = "./modules/sealed-secrets"
  count      = (var.certificate == null) ? 0 : 1

  providers = {
    kubernetes = kubernetes
  }

  certificate = var.certificate
}


module "fluxcd" {
  depends_on = [module.sealed-secrets]
  source     = "./modules/fluxcd"
  count      = (var.github == null) ? 0 : 1

  cluster = {
    name = var.cluster.name
  }

  github = var.github
}