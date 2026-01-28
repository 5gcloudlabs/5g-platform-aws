1- Delete ingress resource, to terminate the ALB and related resources automatically:

kubectl -n istio-system delete ingress ingress

2- Navigate to aws-5gcloudlabs/infrastructure

tofu destroy --auto-approve
