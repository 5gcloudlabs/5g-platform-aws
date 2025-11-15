terraform {

  required_version = ">= 1.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"    
      version = "5.7.1"
    }

  }

    backend "s3" {
      region = var.region
      bucket = var.bucket-name
      key = var.key
}

}


provider "aws" {
  region = var.region
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
  }
}



provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}



provider "kubectl" {
  host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
}
}


provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
