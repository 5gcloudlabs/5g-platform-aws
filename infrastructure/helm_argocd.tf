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
