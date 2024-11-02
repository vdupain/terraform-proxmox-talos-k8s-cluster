resource "flux_bootstrap_git" "this" {

  embedded_manifests   = true
  delete_git_manifests = false
  path                 = "clusters/${var.cluster.name}"
}