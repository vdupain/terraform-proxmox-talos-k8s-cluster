variable "proxmox" {
  description = "Proxmox configuration"
  type = object({
    endpoint  = string
    insecure  = bool
    username  = string
    password  = optional(string)
    api_token = optional(string)
  })
  sensitive = true
}

variable "gitops" {
  description = "GitOps configuration (optional)"
  type = object({
    repository   = string
    token        = string
    cluster_name = string
  })
  default   = null
  sensitive = true
}

variable "certificate" {
  description = "Certificate for k8s sealed-secrets (optional)"
  type = object({
    cert = string
    key  = string
  })
  default   = null
  sensitive = true
}
