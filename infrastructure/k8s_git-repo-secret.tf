resource "kubernetes_secret_v1" "git-repo-secret" {
  depends_on = [kubernetes_namespace_v1.argocd]
  metadata {
    name = "git-repo-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url = "https://github.com/5g-cloud-labs/new-test-2.git" # https://github.com/amrbaraka/priv.git
    username = "5g" #test
    password = "REDACTED" # REDACTED
  }

  type = "Opaque"
}
