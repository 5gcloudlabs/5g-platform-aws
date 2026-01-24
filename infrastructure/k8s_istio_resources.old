#create gw listening on port 443
resource "kubectl_manifest" "istio-gw" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: istio-gw
  namespace: istio-system
spec:
  # The selector matches the ingress gateway pod labels.
  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
  selector:
    istio: gateway #ingress
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - "*"
    tls:
      mode: SIMPLE
      credentialName: "tls-cert-secret"
    EOF
}



#create virtual service pointing to console service
resource "kubectl_manifest" "istio-vs-console" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: istio-vs-console
  namespace: default
spec:
  hosts:
  - "console.${var.domain_name}"
  gateways:
  - istio-system/istio-gw
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: console-service
        port:
          number: 80
EOF
}





#create virtual service pointing to grafana service 
resource "kubectl_manifest" "istio-vs-grafana" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: istio-vs-grafana
  namespace: monitoring #kubernetes_namespace_v1.monitoring.metadata[0].name
spec:
  hosts:
  - "grafana.${var.domain_name}"
  gateways:
  - istio-system/istio-gw
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        port:
          number: 80
        host: kube-prometheus-stack-grafana
EOF
}



#create virtual service pointing to prometheus service 
resource "kubectl_manifest" "istio-vs-prometheus" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: istio-vs-prometheus
  namespace: monitoring #kubernetes_namespace_v1.monitoring.metadata[0].name
spec:
  hosts:
  - "prometheus.${var.domain_name}"
  gateways:
  - istio-system/istio-gw
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        port:
          number: 9090
        host: kube-prometheus-stack-prometheus
EOF
}



#create virtual service pointing to free5gc webui service 
resource "kubectl_manifest" "istio-vs-free5gc" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: istio-vs-free5gc
  namespace: free5gc #kubernetes_namespace_v1.free5gc.metadata[0].name
spec:
  hosts:
  - "webui.${var.domain_name}"
  gateways:
  - istio-system/istio-gw
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        port:
          number: 5000
        host: webui-service
EOF
}





#create virtual service pointing to argocd service 
resource "kubectl_manifest" "istio-vs-argocd" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: istio-vs-argocd
  namespace: argocd
spec:
  hosts:
  - "argocd.${var.domain_name}"
  gateways:
  - istio-system/istio-gw
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: argocd-server
        port:
          number: 80
EOF
}


