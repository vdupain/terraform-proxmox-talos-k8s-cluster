provider "proxmox" {
  endpoint      = var.proxmox.endpoint
  api_token     = var.proxmox.api_token
  insecure      = var.proxmox.insecure
  tmp_dir       = "/tmp"
  random_vm_ids = var.proxmox.random_vm_ids
  ssh {
    agent    = var.proxmox.ssh_agent
    username = var.proxmox.username
    password = var.proxmox.password
  }
}