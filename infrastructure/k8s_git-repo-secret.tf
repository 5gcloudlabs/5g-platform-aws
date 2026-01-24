resource "kubernetes_secret_v1" "git-repo-secret" {
  depends_on = [helm_release.argocd]
  metadata {
    name = "git-repo-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url = "https://github.com/5g-cloud-labs/new-test-2.git" 
    username = "git" #5g
    password = "REDACTED" 
  }

  type = "Opaque"
}
