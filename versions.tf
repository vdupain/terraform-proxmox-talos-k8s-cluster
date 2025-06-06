terraform {
  required_version = ">= 1.8"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.37.1"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">=1.6.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.5.3"
    }
  }
}
