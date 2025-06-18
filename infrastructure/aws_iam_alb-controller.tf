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
