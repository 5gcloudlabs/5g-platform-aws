resource "argocd_application" "nginx_app" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "nginx-app"
    namespace = "argocd"
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/5g-cloud-labs/new-test-2.git"
      target_revision = "trims"
      path            = "argocd-apps/nginx-app"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }

    sync_policy {
      automated {
        prune      = true
        self_heal  = true
      }
    }
  }
}
