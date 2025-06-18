resource "kubernetes_ingress_v1" "ingress-argocd" {
  depends_on = [kubernetes_namespace_v1.argocd, time_sleep.wait_for_alb-controller, module.acm, module.eks, module.vpc]
  metadata {
    name = "ingress-argocd"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" =  "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds": 30
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn" = module.acm.acm_certificate_arn
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "apps"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    rule {
 	  host = "argocd.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }

          path = "/"
		  path_type = "Prefix"
        }
      }    
    }

  }
}




resource "kubernetes_ingress_v1" "ingress-free5gc" {
  depends_on = [kubernetes_namespace_v1.istio-system, time_sleep.wait_for_alb-controller, module.acm, module.eks, module.vpc]
  metadata {
    name = "ingress-free5gc"
	  namespace = kubernetes_namespace_v1.istio-system.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" =  "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds": 30
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn" = module.acm.acm_certificate_arn
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "apps"
    }
  }

  spec {
    rule {
 	  host = "webui.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = "istio-gateway"
              port {
                number = 80
              }
            }
          }

          path = "/"
		  path_type = "Prefix"
        }
      }    
    }
  }
}




resource "kubernetes_ingress_v1" "ingress-grafana" {
  depends_on = [kubernetes_namespace_v1.istio-system, time_sleep.wait_for_alb-controller, module.acm, module.eks, module.vpc]
  metadata {
    name = "ingress-grafana"
	  namespace = kubernetes_namespace_v1.istio-system.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" =  "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds": 30
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn" = module.acm.acm_certificate_arn
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "apps"
    }
  }

  spec {
    rule {
 	  host = "grafana.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = "istio-gateway"
              port {
                number = 80
              }
            }
          }

          path = "/"
		  path_type = "Prefix"
        }
      }    
    }

  }
}




resource "kubernetes_ingress_v1" "ingress-prometheus" {
  depends_on = [kubernetes_namespace_v1.istio-system, time_sleep.wait_for_alb-controller, module.acm, module.eks, module.vpc]
  metadata {
    name = "ingress-prometheus"
	  namespace = kubernetes_namespace_v1.istio-system.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" =  "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds": 30
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn" = module.acm.acm_certificate_arn
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "apps"
    }
  }

  spec {
    rule {
 	  host = "prometheus.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = "istio-gateway"
              port {
                number = 80
              }
            }
          }

          path = "/"
		  path_type = "Prefix"
        }
      }    
    }

  }
}







resource "kubernetes_ingress_v1" "ingress-frontend" {
  depends_on = [kubernetes_namespace_v1.istio-system, time_sleep.wait_for_alb-controller, module.acm, module.eks, module.vpc]
  metadata {
    name = "ingress-frontend"
	  namespace = kubernetes_namespace_v1.istio-system.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" =  "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds": 30
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn" = module.acm.acm_certificate_arn
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "apps"
    }
  }

  spec {
    rule {
 	  host = "frontend.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = "istio-gateway"
              port {
                number = 80
              }
            }
          }

          path = "/"
		  path_type = "Prefix"
        }
      }    
    }

  }
}
