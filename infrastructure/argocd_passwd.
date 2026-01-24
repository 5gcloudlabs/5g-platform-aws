data "kubernetes_secret" "argocd_admin" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

locals {
    depends_on = [data.kubernetes_secret.argocd_admin]
  argocd_password = data.kubernetes_secret.argocd_admin.data.password
}


