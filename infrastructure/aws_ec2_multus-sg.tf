#create security group for AMF n2 interface
resource "aws_security_group" "amf-N2-sg" {
  name        = "amf-N2-sg"
  description = "Allow ingress traffic from gNB"
  vpc_id      = module.vpc.vpc_id
   tags = {
    Name = "amf-N2-sg"
  }
}



#create security group for SMF n4 interface
resource "aws_security_group" "smf-N4-sg" {
  name        = "smf-N4-sg"
  description = "Allow ingress traffic from UPF"
  vpc_id      = module.vpc.vpc_id
   tags = {
    Name = "smf-N4-sg"
  }
}



#create security group for gNB n2 interface
resource "aws_security_group" "gnb-N2-sg" {
  name        = "gnb-N2-sg"
  description = "Allow ingress traffic from AMF"
  vpc_id      = module.vpc.vpc_id
   tags = {
    Name = "gnb-N2-SG"
  }
}

#create security group for UPF n3 interface
resource "aws_security_group" "upf-N3-sg" {
  name        = "upf-N3-sg"
  description = "Allow ingress traffic from gNB"
  vpc_id      = module.vpc.vpc_id
   tags = {
    Name = "upf-N3-sg"
  }
}

#create security group for gNB n3 interface
resource "aws_security_group" "gnb-N3-sg" {
  name        = "gnb-N3-sg"
  description = "Allow N3 ingress from UPF"
  vpc_id      = module.vpc.vpc_id
   tags = {
    Name = "gnb-N3-sg"
  }
}



#create security group for UPF n4 interface
resource "aws_security_group" "upf-N4-sg" {
  name        = "upf-N4-sg"
  description = "Allow ingress traffic from SMF"
  vpc_id      = module.vpc.vpc_id
   tags = {
    Name = "upf-N4-sg"
  }
}

#create security group for UPF n6 interface
resource "aws_security_group" "upf-N6-sg" {
  name        = "upf-N6-sg"
  description = "Allow N6 outbound traffic from UPF"
  vpc_id      = module.vpc.vpc_id
   tags = {
    Name = "upf-N6-sg"
  }
}
