resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace_v1.argocd, helm_release.aws-load-balancer-controller]  
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.2.5"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
}
