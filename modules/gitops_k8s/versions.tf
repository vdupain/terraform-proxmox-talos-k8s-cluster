terraform {
  #required_version = ">= 1.8"
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">=1.5.1"
    }
  }
}
