##Global Parameters##
region = "eu-central-1"


##VPC Parameters##
vpc_name = "cloud-5g-vpc"
vpc_cidr = "192.168.0.0/16"                  # "192.168.0.0/16" or "172.16.0.0/12" or "10.0.0.0/8" https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html
azs = ["eu-central-1b", "eu-central-1c"]     # Define two Availability Zones inside the region




##EKS Parameters##
eks_cluster_name = "cloud-5g-eks"
ami_id = "ami-064c2479baf726e71"             #image list per region: https://cloud-images.ubuntu.com/docs/aws/eks/




##DNS Parameters##
cloudflare_api_token = "REDACTED_CLOUDFLARE_API_TOKEN"
domain_name = "tclouds.co.uk" #"cloud-5g.io"
zone_id = "6245dceda9757a901b9e034520802b74" #"f13499d719a8bddb157a500c487ba064"


##S3 Bucket Parameters##
bucket = "cloud-5g-terraform-state-s3"
key = "terraform.tfstate"
