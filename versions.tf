terraform {
  required_version = ">= 1.8"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.7"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.6"
    }
  }
}
