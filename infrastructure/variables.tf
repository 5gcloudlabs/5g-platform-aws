##Global Parameters##

variable "region" {
  description = "AWS Region where resources will be created"
  type = string
  default = "eu-central-1"
}


##S3 Parameters##

variable "bucket-name" {
  description = "Name of the S3 bucket hosting state file"
  type = string
}


variable "key" {
  description = "Name & Path of the state file"
  type = string
}


#VPC Parameters##

variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "cloud-5g-vpc"
}

variable "vpc_cidr" {
  description = "Primary CIDR of the VPC"
  type = string
  default = "192.168.0.0/16"
}

variable "azs" {
  description = "List of Availability Zones for VPC subnets"
  type = list(string)
  default = ["eu-central-1b", "eu-central-1c"]
}


##EKS Parameters##

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type = string
  default = "cloud-5g-eks"
}


variable "ami_id" {
  description = "Ubuntu AMI ID optimized for EKS worker nodes."
  type = string
  default = "ami-064c2479baf726e71"
}



##AI Parameters

variable "bedrock_region" {
  description = "Bedrock region override. Leave empty if defined <region> 'under Global Parameters', hosts Bedrock." ##https://docs.aws.amazon.com/general/latest/gr/bedrock.html
  type = string
  default = ""
}


variable "bedrock_model_id" {
  description = "Bedrock model or inference profile ID for the Telco Deployment Assistant (Anthropic Claude Haiku 4.5)."
  type = string
  default = "global.anthropic.claude-haiku-4-5-20251001-v1:0"
}


##DNS Parameters##

variable "cloudflare_api_token" {
  description = "cloudflare access api token utilized by cloudflare provider and external-dns"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The domain name of the hosted zone registered with DNS provider"
  type = string
}

variable "zone_id" {
  description = "Cloudflare zone ID for the domain_name hosted zone"
  type        = string
}

variable "git_repo_url" {
  description = "Git repository URL registered with Argo CD for platform manifests."
  type        = string
  default     = "https://github.com/5gcloudlabs/5g-platform-aws.git"
}

variable "git_repo_username" {
  description = "Username for Argo CD Git repository credentials (ignored when password is empty)."
  type        = string
  default     = "git"
  sensitive   = true
}

variable "git_repo_password" {
  description = "Password or PAT for Argo CD Git repository access. Leave empty for public repositories."
  type        = string
  default     = ""
  sensitive   = true
}


