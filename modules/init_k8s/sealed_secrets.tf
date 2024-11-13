resource "kubernetes_namespace" "sealed_secrets" {
  metadata {
    name = "sealed-secrets"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels["kustomize.toolkit.fluxcd.io/name"],
      metadata[0].labels["kustomize.toolkit.fluxcd.io/namespace"],
      metadata[0].labels["vector.dev/exclude"],
    ]
  }
}

resource "kubernetes_secret" "sealed_secrets_key" {
  depends_on = [kubernetes_namespace.sealed_secrets]
  type       = "kubernetes.io/tls"

  metadata {
    name      = "sealed-secrets-bootstrap-key"
    namespace = "sealed-secrets"
    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }

  data = {
    "tls.crt" = var.certificate.cert
    "tls.key" = var.certificate.key
  }
}

