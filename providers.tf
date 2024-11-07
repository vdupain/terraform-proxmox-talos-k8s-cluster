locals {
  kubernetes = {
    host                   = module.talos_k8s.kube_config.kubernetes_client_configuration.host
    client_certificate     = base64decode(module.talos_k8s.kube_config.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.talos_k8s.kube_config.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(module.talos_k8s.kube_config.kubernetes_client_configuration.ca_certificate)
  }
}

provider "kubernetes" {
    host                   = local.kubernetes.host
    client_certificate     = local.kubernetes.client_certificate
    client_key             = local.kubernetes.client_key
    cluster_ca_certificate = local.kubernetes.cluster_ca_certificate
}

provider "flux" {
  kubernetes = local.kubernetes
  git = {
    url = (var.github != null) ? "https://github.com/${var.github.org}/${var.github.repository}.git" : "https://dummy"
    http = {
      username = "git" # This can be any string when using a personal access token
      password = (var.github != null) ? var.github.token : null
    }
  }
}
