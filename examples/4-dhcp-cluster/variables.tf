variable "proxmox" {
  type = object({
    endpoint  = string
    insecure  = bool
    username  = string
    password  = string
    api_token = string
  })
  sensitive = true
}
