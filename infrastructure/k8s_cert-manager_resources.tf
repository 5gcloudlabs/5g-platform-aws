resource "kubectl_manifest" "cluster-issuer" {
  depends_on = [helm_release.cert-manager]
    yaml_body = <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cluster-issuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cluster-issuer-account-key
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret-cert-manager-ns
            key: cloudflare-api-token
    EOF
}


resource "kubectl_manifest" "tls-cert" {
  depends_on = [helm_release.cert-manager]
    yaml_body = <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls-cert
  namespace: istio-system
spec:
  issuerRef:
    name: cluster-issuer
    kind: ClusterIssuer
  secretName: tls-cert-secret
  commonName: "${var.domain_name}"
  dnsNames:
    - "${var.domain_name}"
    - "*.${var.domain_name}"
EOF
}
