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


##DNS Parameters##

variable "dns_provider_name" {
  description = "Name of the DNS provider where hosted zone is registered with"
  type = string
  default = "cloudflare"
}


variable "cloudflare_api_token" {
  description = "cloudflare access api token utilized by cloudflare provider and external-dns"
}

variable "domain_name" {
  description = "The domain name of the hosted zone registered with DNS provider"
  type = string
}

variable "zone_id" {
  description = "ID of the DNS zone registered with the DNS provider"
  type = string
}

