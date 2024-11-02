terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">=1.4.0"
    }
  }
}
