resource "kubernetes_secret_v1" "git-repo-secret" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "git-repo-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = merge(
    {
      type = "git"
      url  = var.git_repo_url
    },
    var.git_repo_password != "" ? {
      username = var.git_repo_username
      password = var.git_repo_password
    } : {}
  )

  type = "Opaque"
}
