#Install Istio base chart
resource "helm_release" "istio-base" {
  depends_on       = [helm_release.argocd]
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  name             = "istio-base"
  namespace        = kubernetes_namespace_v1.istio-system.metadata[0].name
  #create_namespace = true
}

#Install Istio discovery chart
resource "helm_release" "istiod" {
  depends_on       = [helm_release.istio-base] 
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  name             = "istiod"
  namespace        = "istio-system"
  timeout          = 300
}

#Install an ingress gateway
resource "helm_release" "istio-gateway" {
  depends_on = [helm_release.istiod, aws_security_group_rule.allow_sidecar_injection_SG_rule]
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  name       = "istio-gateway"
  namespace  = "istio-system"

  set = [ {
    name  = "service.type"
    value = "NodePort"
  }
 ]
}
