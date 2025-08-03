#Create VPC using module "vpc"

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  name = var.vpc_name 
  cidr = var.vpc_cidr

  azs             = ["eu-central-1b", "eu-central-1c"]

  public_subnets = [cidrsubnet(var.vpc_cidr, 3, 0), cidrsubnet(var.vpc_cidr, 3, 2),]
  private_subnets  = [cidrsubnet(var.vpc_cidr, 3, 1), cidrsubnet(var.vpc_cidr, 3, 3),]

  private_subnet_tags = {"kubernetes.io/role/internal-elb" = "1" 
                          "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
                          "Tier" = "Private"}

  public_subnet_tags = {"kubernetes.io/role/elb" = "1"
                        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"}

  enable_nat_gateway = true
  one_nat_gateway_per_az = true

  
}


resource "time_sleep" "sleep-after-vpc-creation" {
depends_on = [module.vpc]

    create_duration = "3m"
}


resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.0.0/16"
}

