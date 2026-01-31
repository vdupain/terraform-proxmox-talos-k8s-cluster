module "vms_proxmox" {
  source  = "./modules/vms_proxmox"
  proxmox = var.proxmox
  cluster = {
    name                  = var.cluster.name
    gateway               = var.cluster.gateway
    dns_domain            = var.cluster.dns_domain
    dns_servers           = var.cluster.dns_servers
    cidr                  = var.cluster.cidr
    vlan_id               = var.cluster.vlan_id
    talos_version         = var.cluster.talos_version
    network_dhcp          = var.cluster.network_dhcp
    network_device_bridge = var.cluster.network_device_bridge
  }

  additional_extensions = var.additional_extensions
  vms                   = var.vms
  pci                   = var.pci
}

module "talos_k8s" {
  depends_on = [module.vms_proxmox]
  source     = "./modules/talos_k8s"
  cluster = {
    name                               = var.cluster.name
    endpoint                           = var.cluster.endpoint
    network_dhcp                       = var.cluster.network_dhcp
    allow_scheduling_on_control_planes = var.cluster.allow_scheduling_on_control_planes
    vip_ip                             = var.cluster.vip_ip
    vip_interface                      = var.cluster.vip_interface
  }

  nodes = { for k, vm in var.vms : k => merge(vm, {
    ip = lookup(module.vms_proxmox.qemu_ipv4_addresses, k, vm.ip)
  }) }
}

module "init_k8s" {
  depends_on = [module.talos_k8s]
  source     = "./modules/init_k8s"
  count      = (var.certificate == null) ? 0 : 1
  providers = {
    kubernetes = kubernetes
  }

  certificate = var.certificate
}

module "gitops_k8s" {
  depends_on = [module.init_k8s]
  source     = "./modules/gitops_k8s"
  count      = (var.gitops == null) ? 0 : 1

  gitops = var.gitops
}
