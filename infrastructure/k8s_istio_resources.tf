
#create gw listening on port 80 
resource "kubectl_manifest" "istio-gw-grafana" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-gw-grafana
  namespace: monitoring #kubernetes_namespace_v1.monitoring.metadata[0].name
spec:
  # The selector matches the ingress gateway pod labels.
  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
  selector:
    istio: gateway #ingress
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "grafana.${var.domain_name}"
    EOF
}



#create virtual service pointing to grafana service 
resource "kubectl_manifest" "istio-vs-grafana" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: istio-vs-grafana
  namespace: monitoring #kubernetes_namespace_v1.monitoring.metadata[0].name
spec:
  hosts:
  - "grafana.${var.domain_name}"
  gateways:
  - istio-gw-grafana
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

################

#create gw listening on port 80 
resource "kubectl_manifest" "istio-gw-prometheus" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-gw-prometheus
  namespace: monitoring #kubernetes_namespace_v1.monitoring.metadata[0].name
spec:
  # The selector matches the ingress gateway pod labels.
  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
  selector:
    istio: gateway #ingress
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "prometheus.${var.domain_name}"
    EOF
}



#create virtual service pointing to prometheus service 
resource "kubectl_manifest" "istio-vs-prometheus" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: istio-vs-prometheus
  namespace: monitoring #kubernetes_namespace_v1.monitoring.metadata[0].name
spec:
  hosts:
  - "prometheus.${var.domain_name}"
  gateways:
  - istio-gw-prometheus
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

################

#create gw listening on port 80 
resource "kubectl_manifest" "istio-gw-free5gc" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-gw-free5gc
  namespace: free5gc #kubernetes_namespace_v1.free5gc.metadata[0].name
spec:
  # The selector matches the ingress gateway pod labels.
  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
  selector:
    istio: gateway #ingress
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "webui.${var.domain_name}"
    EOF
}




#create virtual service pointing to free5gc webui service 
resource "kubectl_manifest" "istio-vs-free5gc" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: istio-vs-free5gc
  namespace: free5gc #kubernetes_namespace_v1.free5gc.metadata[0].name
spec:
  hosts:
  - "webui.${var.domain_name}"
  gateways:
  - istio-gw-free5gc
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


################



################

##create gw listening on port 443 
#resource "kubectl_manifest" "istio-gw-argocd" {
#  depends_on = [helm_release.istio-ingress]
#    yaml_body = <<EOF
#apiVersion: networking.istio.io/v1alpha3
#kind: Gateway
#metadata:
#  name: istio-gw-argocd
#  namespace: argocd #kubernetes_namespace_v1.argocd.metadata[0].name
#spec:
#  # The selector matches the ingress gateway pod labels.
#  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
#  selector:
#    istio: gateway #ingress
#  servers:
#  - port:
#      number: 443
#     name: https
#      protocol: HTTPS
#    hosts:
#    - "argocd.tclouds.co.uk"
#    EOF
#}
#
#
#
##create virtual service pointing to argocd service 
#resource "kubectl_manifest" "istio-vs-argocd" {
#  depends_on = [helm_release.istio-ingress]
#    yaml_body = <<EOF
#apiVersion: networking.istio.io/v1alpha3
#kind: VirtualService
#metadata:
#  name: istio-vs-argocd
#  namespace: argocd #kubernetes_namespace_v1.argocd.metadata[0].name
#spec:
#  hosts:
#  - "argocd.tclouds.co.uk"
#  gateways:
#  - istio-gw-argocd
#  http:
#  - match:
#    - uri:
#        prefix: /
#    route:
#    - destination:
#        port:
#          number: 443
#        host: argocd-server
#EOF
#}










################

#create gw listening on port 80 
resource "kubectl_manifest" "istio-gw-frontend" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-gw-frontend
  namespace: default 
spec:
  # The selector matches the ingress gateway pod labels.
  # If you installed Istio using Helm following the standard documentation, this would be "istio=ingress"
  selector:
    istio: gateway #ingress
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "frontend.${var.domain_name}"
    EOF
}




#create virtual service pointing to frontend service 
resource "kubectl_manifest" "istio-vs-frontend" {
  depends_on = [helm_release.istio-gateway]
    yaml_body = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: istio-vs-frontend
  namespace: default
spec:
  hosts:
  - "frontend.${var.domain_name}"
  gateways:
  - istio-gw-frontend
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: frontend-service
        port:
          number: 80
EOF
}


################
