provider "proxmox" {
  endpoint           = var.proxmox.endpoint
  api_token          = var.proxmox.api_token
  insecure           = var.proxmox.insecure
  tmp_dir            = "/tmp"
  random_vm_ids      = var.proxmox.random_vm_ids
  random_vm_id_start = var.proxmox.random_vm_id_start
  random_vm_id_end   = var.proxmox.random_vm_id_end

  ssh {
    agent    = var.proxmox.ssh_agent
    username = var.proxmox.username
    password = var.proxmox.password
  }
}