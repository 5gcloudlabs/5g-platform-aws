# Set environment variable
resource "kubernetes_env" "vpc-cni" {
  depends_on       = [module.eks]
  container = "aws-node"
  metadata {
    name      = "aws-node"
    namespace = "kube-system"
  }
  api_version = "apps/v1"
  kind        = "DaemonSet"


 env {
 name = "WARM_ENI_TARGET"
 value = "0"
 }


  force = true
}


resource "time_sleep" "sleep-after-env-variable" {
depends_on = [kubernetes_env.vpc-cni]

    create_duration = "3m"
}