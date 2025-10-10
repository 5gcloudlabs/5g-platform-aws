resource "kubernetes_secret_v1" "cloudflare-api-token-secret-cert-manager-ns" {
  depends_on = [kubernetes_namespace_v1.cert-manager]
  metadata {
    name = "cloudflare-api-token-secret-cert-manager-ns"
    namespace = "cert-manager"
  }

  data = {
    cloudflare-api-token = var.cloudflare_api_token
  }

  type = "Opaque"

}
