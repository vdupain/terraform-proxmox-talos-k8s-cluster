terraform {
  required_version = ">= 1.8"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
  }
}
