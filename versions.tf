terraform {
  required_version = ">= 1.8"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">=1.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.5.2"
    }
  }
}
