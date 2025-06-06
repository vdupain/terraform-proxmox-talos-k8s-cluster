terraform {
  required_version = ">= 1.8"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.78.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.5.0"
    }
  }
}
