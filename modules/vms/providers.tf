provider "proxmox" {
  endpoint      = var.proxmox.endpoint
  api_token     = var.proxmox.api_token
  insecure      = var.proxmox.insecure
  tmp_dir       = "/tmp"
  random_vm_ids = true
  ssh {
    agent    = false
    username = var.proxmox.username
    password = var.proxmox.password
  }
}