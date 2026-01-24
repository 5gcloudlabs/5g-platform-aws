resource "helm_release" "cert-manager" {
  depends_on       = [helm_release.argocd]
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  name             = "cert-manager"
  version          = "v1.18.2"
  namespace        = kubernetes_namespace_v1.cert-manager.metadata[0].name

  set = [ {
    name  = "crds.enabled"
    value = "true"
  }
 ]


}
