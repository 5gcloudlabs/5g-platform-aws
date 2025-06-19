#Install aws-load-balancer-controller chart
resource "helm_release" "aws-load-balancer-controller" {
  depends_on = [aws_ssm_association.ssm_association_5gcp_node]
  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  

  set = [
  {
    name  = "clusterName"
    value = module.eks.cluster_name
  },

  {
    name  = "replicaCount"
    value = 1
  },

  {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  },
  
  {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller_role.arn
  }
]

}

resource "time_sleep" "wait_for_alb-controller" {

    depends_on = [
        helm_release.aws-load-balancer-controller
    ]

    create_duration = "20s"
}
