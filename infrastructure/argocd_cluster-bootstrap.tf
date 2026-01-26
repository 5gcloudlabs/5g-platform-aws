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
    path: cluster-bootstrap/argocd-apps/required-apps
    plugin:
      name: envsubst
      env:
      - name: DOMAIN_NAME
        value: ${var.domain_name}
      - name: CF_API_TOKEN
        value: ${var.cloudflare_api_token}
      - name: ACM_CERTIFICATE_ARN
        value: ${module.acm.acm_certificate_arn}
      - name: EKS_CLUSTER_NAME
        value: ${module.eks.cluster_name}
      - name: LBC_IAM_ROLE_ARN
        value: ${aws_iam_role.aws_load_balancer_controller_role.arn}
      - name: EFS_ARN
        value: ${aws_iam_role.aws_efs_csi_driver_role.arn}
      - name: EFS_ID
        value: ${module.efs.id}
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
}
