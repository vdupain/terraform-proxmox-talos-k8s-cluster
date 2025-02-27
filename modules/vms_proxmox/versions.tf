terraform {
  required_version = ">= 1.8"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.73.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.4.5"
    }
  }
}
