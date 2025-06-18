#Install aws-efs-csi-driver chart
resource "helm_release" "aws-efs-csi-driver" {
  depends_on = [module.efs, aws_ssm_association.ssm_association_5gcp_node]
  name = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  

  set {
    name  = "replicaCount"
    value = 1
  }


#create service account for controller pod and set the annotation using the created iam role
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_efs_csi_driver_role.arn
  }


set {
    name  = "controller.logLevel"
    value = 5
  }

#create service account for node pod and set the annotation using the created iam role
  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_efs_csi_driver_role.arn
  }


set {
    name  = "node.logLevel"
    value = 5
  }

}



