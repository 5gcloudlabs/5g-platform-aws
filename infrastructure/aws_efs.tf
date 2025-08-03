#create efs using "efs" module
module "efs" {
  source = "terraform-aws-modules/efs/aws"
  version = "1.8.0"

    name           = "efs"
    mount_targets = {
    
    (module.vpc.azs[1]) = {subnet_id = module.vpc.private_subnets[1]}
  }

    attach_policy = false

#create security group for efs with required ingress & egress rules.
security_group_description = "EFS_security_group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_rules = {
    ingress = {
      description = "NFS ingress from VPC"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    },
    #allow all egress traffic
    egress = {
      description = "allow all egress traffic"
      type                     = "egress"
      to_port                  = 0
      protocol                 = "-1"
      from_port                = 0
      security_group_id        = module.efs.security_group_id
      cidr_blocks               = ["0.0.0.0/0"]
  
    }
  }

}
