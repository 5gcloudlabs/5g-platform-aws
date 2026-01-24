#create storage class
resource "kubernetes_storage_class_v1" "storage-class" {
  depends_on       = [module.efs, module.eks]
  metadata {
    name = "efs-sc" #needs to match value of parameter "storageClassName" in mongo-db values.yaml 
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId = module.efs.id
    directoryPerms = "700"
    gidRangeStart = "1001" #needs to match the value of parameters podSecurityContext_fsGroup & containerSecurityContext_runAsUser
    gidRangeEnd = "1002"
    basePath = "/dynamic_provisioning"

  }
}