#input Assume-role-policy/trust-relationship to grant service account "aws-load-balancer-controller" AssumeRoleWithWebIdentity action

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
    
    statement {
            actions = ["sts:AssumeRoleWithWebIdentity"]
            effect = "Allow"

        condition {

            test =  "StringEquals"
            variable = "${module.eks.oidc_provider}:sub"
            values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
            
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
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  name               = "aws_load_balancer_controller_role"
}


#input aws_load_balancer_controller IAM policy that allows the ALB Controller service account to make calls to AWS APIs
data "http" "aws_load_balancer_controller_policy_input" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

#create aws_load_balancer_controller IAM policy
resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name = "aws_load_balancer_controller_iam_policy"
  policy = data.http.aws_load_balancer_controller_policy_input.response_body
}



#attach aws iam policy to the iam role
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_role_attach" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}


###

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



######################################################################################


###

# Assume-role-policy/trust-relationship to grant service account "network-deployment-agent" in "network-deployment-agent" namespace AssumeRoleWithWebIdentity action

data "aws_iam_policy_document" "network_deployment_agent_bedrock_assume_role_policy" {

    statement {
            actions = ["sts:AssumeRoleWithWebIdentity"]
            effect = "Allow"

        condition {

            test =  "StringEquals"
            variable = "${module.eks.oidc_provider}:sub"
            values = ["system:serviceaccount:network-deployment-agent:network-deployment-agent"]

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


# Create IAM role associating with created assume role policy
resource "aws_iam_role" "network_deployment_agent_bedrock_role" {
  assume_role_policy = data.aws_iam_policy_document.network_deployment_agent_bedrock_assume_role_policy.json
  name               = "network_deployment_agent_bedrock_role"
}


# Create Bedrock IAM policy allowing model invocation
resource "aws_iam_policy" "network_deployment_agent_bedrock_policy" {
  name = "network_deployment_agent_bedrock_iam_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:*:*:inference-profile/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "aws-marketplace:Subscribe",
          "aws-marketplace:Unsubscribe",
          "aws-marketplace:ViewSubscriptions"
        ]
        Resource = "*"
      }
    ]
  })
}


# Attach Bedrock policy to the IAM role
resource "aws_iam_role_policy_attachment" "network_deployment_agent_bedrock_role_attach" {
  role       = aws_iam_role.network_deployment_agent_bedrock_role.name
  policy_arn = aws_iam_policy.network_deployment_agent_bedrock_policy.arn
}
