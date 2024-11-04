variable "proxmox" {
  description = "Proxmox configuration"
  type = object({
    endpoint  = string
    insecure  = bool
    username  = string
    password  = string
    api_token = optional(string)
  })
  sensitive = true
}

variable "github" {
  description = "Github configuration"
  type = object({
    token      = string
    org        = string
    repository = string
  })
  default = null
}
