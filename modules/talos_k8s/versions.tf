terraform {
  required_version = ">= 1.8"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">=0.7.1"
    }
  }
}
