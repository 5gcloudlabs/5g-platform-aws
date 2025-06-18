

resource "helm_release" "external-dns" {
  depends_on = [aws_ssm_association.ssm_association_5gcp_node]
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"

  

  set {
  name  = "provider.name"
  value = var.dns_provider_name
} 

  set {
  name  = "env[0].name"
  value = "CF_API_TOKEN"
}

set {
  name  = "env[0].valueFrom.secretKeyRef.name"
  value = "cloudflare-api-token-secret"
}

set {
  name  = "env[0].valueFrom.secretKeyRef.key"
  value = "cloudflare-api-token"
}


set {
    name  = "domainFilters[0]"
    value = var.domain_name 
  }


  set {
    name  = "policy"
    value = "sync"
  }

  
  
  set {
    name  = "txtOwnerId" # TXT record identifier
    value = "external-dns"
  }
}
