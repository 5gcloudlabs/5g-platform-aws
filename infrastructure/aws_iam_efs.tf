#input Assume-role-policy/trust-relationship to grant service accounts "efs-csi-controller & efs-csi-node" AssumeRoleWithWebIdentity action   

data "aws_iam_policy_document" "efs_csi_driver_assume_role_policy" {
    
    statement {
            actions = ["sts:AssumeRoleWithWebIdentity"]
            effect = "Allow"

        condition {

            test =  "StringEquals"
            variable = "${module.eks.oidc_provider}:sub"
            values = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
            
            }

        condition {

            test =  "StringEquals"
            variable = "${module.eks.oidc_provider}:aud"
            values = ["sts.amazonaws.com"]
            
            }    

        principals {
                type = "Federated"
                identifiers =  ["${module.eks.oidc_provider_arn}"]
            }
            
            
        }
    


statement {
            actions = ["sts:AssumeRoleWithWebIdentity"]
            effect = "Allow"

        condition {

            test =  "StringEquals"
            variable = "${module.eks.oidc_provider}:sub"
            values = ["system:serviceaccount:kube-system:efs-csi-node-sa"]
            
            }

        condition {

            test =  "StringEquals"
            variable = "${module.eks.oidc_provider}:aud"
            values = ["sts.amazonaws.com"]
            
            }    

        principals {
                type = "Federated"
                identifiers =  ["${module.eks.oidc_provider_arn}"]
            }
            
            
        }


}


#create iam role associating with created assume role policy
resource "aws_iam_role" "aws_efs_csi_driver_role" {
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver_assume_role_policy.json
  name               = "aws_efs_csi_driver_role"
}


#input aws efs IAM policy that allows the CSI driver service account to make calls to AWS APIs
data "http" "aws_efs_policy_input" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json"

  request_headers = {
    Accept = "application/json"
  }
}

#create aws efs IAM policy
resource "aws_iam_policy" "aws_efs_policy" {
  name = "aws_efs_csi_iam_policy"
  policy = data.http.aws_efs_policy_input.response_body
}


#attach aws efs policy to the iam role
resource "aws_iam_role_policy_attachment" "aws_efs_csi_driver_role_attach" {
  role       = aws_iam_role.aws_efs_csi_driver_role.name
  policy_arn = aws_iam_policy.aws_efs_policy.arn
}
