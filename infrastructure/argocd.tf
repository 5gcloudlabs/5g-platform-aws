#install argocd helm chart with cmp plugin
resource "helm_release" "argocd" {
  depends_on = [ aws_ssm_association.ssm_association_5gcp_node ]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.2.5"
  namespace  = "argocd"
  create_namespace = true
  wait                  = true
  timeout               = 300
  atomic                = false
  render_subchart_notes = true
  values = [
    yamlencode({
      configs = {
        params = {
          "server.insecure" = true
        }

        cmp = {
          create = true

          plugins = {
            envsubst = {
              generate = {
                command = ["sh", "-c"]
                args = [
                  <<-EOF
                  set -e
                  find . -type f -name '*.yaml' -o -name '*.yml' | while read -r file; do
                   echo "---"
                    envsubst < "$file"
                     done
                  EOF
                ]
              }
            }
          }
        }
      }

      repoServer = {
        extraContainers = [
          {
            name    = "cmp-envsubst"
            image   = "ghcr.io/5g-cloud-labs/argocd-cmp-envsubst/argocd-cmp-envsubst:v1"
            command = ["/var/run/argocd/argocd-cmp-server"]

            securityContext = {
              runAsNonRoot = true
              runAsUser    = 999
            }

            volumeMounts = [
              {
                name      = "var-files"
                mountPath = "/var/run/argocd"
              },
              {
                name      = "plugins"
                mountPath = "/home/argocd/cmp-server/plugins"
              },
              {
                name      = "argocd-cmp-cm"
                mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
                subPath   = "envsubst.yaml"
              },
              {
                name      = "cmp-tmp"
                mountPath = "/tmp"
              }
            ]
          }
        ]

        volumes = [
          {
            name = "argocd-cmp-cm"
            configMap = {
              name = "argocd-cmp-cm"
            }
          },
          {
            name     = "cmp-tmp"
            emptyDir = {}
          }
        ]
      }
    })
  ]
}


#argocd app of apps to bootstrap EKS cluster
resource "kubectl_manifest" "cluster_bootstrap" {
  depends_on = [helm_release.argocd]
  yaml_body = <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-bootstrap
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/5g-cloud-labs/new-test-2.git
    targetRevision: 5g-platform-aws
    path: cluster-bootstrap/argocd-apps/required-apps
    plugin:
      name: envsubst
      env:
      - name: REGION
        value: ${var.region}
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
      - name: NETWORK_DEPLOYMENT_AGENT_BEDROCK_ROLE_ARN
        value: ${aws_iam_role.network_deployment_agent_bedrock_role.arn}
      - name: BEDROCK_REGION
        value: ${coalesce(var.bedrock_region, var.region)}
      - name: BEDROCK_MODEL_ID
        value: ${var.bedrock_model_id}
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
}
