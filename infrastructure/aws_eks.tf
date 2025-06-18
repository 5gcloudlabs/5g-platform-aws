#Create EKS cluster using module "eks"


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_cluster_name
  


  vpc_id = module.vpc.vpc_id

  subnet_ids = [module.vpc.private_subnets[0],module.vpc.private_subnets[1]]

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true
  
  eks_managed_node_group_defaults = {
    disk_size              = 30
    enable_bootstrap_user_data = true # to opt in to using the module supplied bootstrap user data template
  }

#Specify the node groups in eks cluster
  eks_managed_node_groups = {
    
    

#node group for 5g core control-plane deployments:
controlplane5g-ng = {
      depends_on = [time_sleep.sleep-after-vpc-creation]
      name = "5g-controlplane-node"
      subnet_ids = [module.vpc.private_subnets[1]]


      instance_types = ["m5.4xlarge"]
      ami_id = var.ami_id #"ami-00142e8f1e0ae8c22"  #"ami-064c2479baf726e71"
      iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

post_bootstrap_user_data = <<EOF
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https net-tools make git vim
sudo apt install -y binutils gcc libsctp-dev lksctp-tools
EOF
    
      

      labels = {
       controlplane = "true"
   }
      
      min_size     = 1
      max_size     = 1
      desired_size = 1


    }

#node group for 5g core UPF User-Plane Function + UE/RAN Simulator:
userplane5g-ng = {
      depends_on = [time_sleep.sleep-after-vpc-creation]
      name = "5g-userplane-node"
      subnet_ids = [module.vpc.private_subnets[0]]


      instance_types = ["c4.4xlarge"]
      ami_id = var.ami_id #"ami-00142e8f1e0ae8c22"  #"ami-064c2479baf726e71"
      iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

post_bootstrap_user_data = <<EOF
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https net-tools make git vim
sudo apt install -y binutils gcc libsctp-dev lksctp-tools
git clone -b v0.8.10 https://github.com/free5gc/gtp5g.git
cd gtp5g
make
sudo make install
EOF
    
      

      labels = {
       userplane = "true"
   }
      
      min_size     = 1
      max_size     = 1
      desired_size = 1


    }

  }

  }


  
