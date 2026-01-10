resource "kubectl_manifest" "required_apps" {
  depends_on = [helm_release.argocd]
  yaml_body = <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: required-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/5g-cloud-labs/new-test-2.git
    targetRevision: trims
    path: argocd-apps/required-apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
}
