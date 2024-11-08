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

variable "gitops" {
  description = "GitOps configuration"
  type = object({
    repository   = string
    token        = string
    cluster_name = string
  })
  default = null
}
