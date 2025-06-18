resource "kubernetes_namespace_v1" "argocd" {
    depends_on       = [module.eks]
    metadata {
        name = "argocd"
    
    }
}


resource "kubernetes_namespace_v1" "monitoring" {
    depends_on       = [module.eks]
    metadata {
        name = "monitoring"
    
    }
}

resource "kubernetes_namespace_v1" "free5gc" {
    depends_on       = [module.eks]
    metadata {
        name = "free5gc"
    labels = {
        "istio-injection" = "enabled"
    }    
    
    }
}


resource "kubernetes_namespace_v1" "ueransim" {
    depends_on       = [module.eks]
    metadata {
        name = "ueransim"
    labels = {
        "istio-injection" = "enabled"
    }
    
    }
}


resource "kubernetes_namespace_v1" "istio-system" {
    depends_on       = [module.eks]
    metadata {
        name = "istio-system"
    
    }
}