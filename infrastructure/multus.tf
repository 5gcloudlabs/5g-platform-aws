# Create Multus Subnets for Control-Plane Node:


#create subnet for AMF n2 interface
resource "aws_subnet" "amf-N2-subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  vpc_id     = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block = "100.64.1.0/28"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "amf-N2-subnet"
  }
}

#explicit subnet CIDR reservation
#resource "aws_ec2_subnet_cidr_reservation" "amf-N2-subnet" {
#  cidr_block       = "100.64.1.0/28"
#  reservation_type = "explicit"
#  subnet_id        = aws_subnet.amf-N2-subnet.id
#}





#create subnet for SMF n4 interface
resource "aws_subnet" "smf-N4-subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  vpc_id     = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block = "100.64.4.0/28"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "smf-N4-subnet"
  }
}

#explicit subnet CIDR reservation
#resource "aws_ec2_subnet_cidr_reservation" "smf-N4-subnet" {
#  cidr_block       = "100.64.4.0/28"
#  reservation_type = "explicit"
#  subnet_id        = aws_subnet.smf-N4-subnet.id
#}


###############################################

#Create Multus Subnets for User-Plane Node:

#create subnet for UPF n6 interface
resource "aws_subnet" "free5gc-upf-N6-subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.6.0/28"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "free5gc-upf-N6-subnet"
  }
}

#explicit subnet CIDR reservation
#resource "aws_ec2_subnet_cidr_reservation" "upf-N6-subnet" {
#  cidr_block       = "100.64.6.0/28"
#  reservation_type = "explicit"
#  subnet_id        = aws_subnet.free5gc-upf-N6-subnet.id
#}



#create subnet for UPF n4 interface
resource "aws_subnet" "free5gc-upf-N4-subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.5.0/28"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "free5gc-upf-N4-subnet"
  }
}


#explicit subnet CIDR reservation
#resource "aws_ec2_subnet_cidr_reservation" "upf-N4-subnet" {
#  cidr_block       = "100.64.5.0/28"
#  reservation_type = "explicit"
#  subnet_id        = aws_subnet.free5gc-upf-N4-subnet.id
#}


#create subnet for gNB n3 interface
resource "aws_subnet" "ueransim-gnb-N3-subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.2.0/28"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "ueransim-gnb-N3-subnet"
  }
}


#explicit subnet CIDR reservation
#resource "aws_ec2_subnet_cidr_reservation" "gnb-N3-subnet" {
#  cidr_block       = "100.64.2.0/28"
#  reservation_type = "explicit"
#  subnet_id        = aws_subnet.ueransim-gnb-N3-subnet.id
#}

#create subnet for UPF n3 interface
resource "aws_subnet" "upf-N3-subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.3.0/28"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "free5gc-upf-N3-subnet"
  }
}


#explicit subnet CIDR reservation
#resource "aws_ec2_subnet_cidr_reservation" "upf-N3-subnet" {
#  cidr_block       = "100.64.3.0/28"
#  reservation_type = "explicit"
#  subnet_id        = aws_subnet.upf-N3-subnet.id
#}




#create subnet for gNB n2 interface
resource "aws_subnet" "ueransim-gnb-N2-subnet" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.0.0/28"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "ueransim-gnb-N2-subnet"
  }
}

#explicit subnet CIDR reservation
#resource "aws_ec2_subnet_cidr_reservation" "gnb-N2-subnet" {
#  cidr_block       = "100.64.0.0/28"
#  reservation_type = "explicit"
#  subnet_id        = aws_subnet.ueransim-gnb-N2-subnet.id
#}



##Multus ENI creation and attachments for Control-Plane Node:

#Fetch information of the existing eks worker node named "5g-controlplane-node"
data "aws_instance" "_5gcontrolplane-node" {
  depends_on = [module.eks.eks_managed_node_groups]

  filter {
    name   = "tag:Name"
    values = ["5g-controlplane-node"]
  }
  
}

#create amf-N2-eni
resource "aws_network_interface" "amf-N2-eni" {
  subnet_id       = aws_subnet.amf-N2-subnet.id
  private_ips     = ["100.64.1.9"]
  security_groups = [aws_security_group.amf-N2-sg.id]
  tags = {
    Name = "amf-N2-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
    }
  }

  #Attach to amf-N2-eni to free5gc node
  resource "aws_network_interface_attachment" "amf-N2-eni-attachment" {
  depends_on = [time_sleep.sleep-after-env-variable]
  instance_id          = data.aws_instance._5gcontrolplane-node.id
  network_interface_id = aws_network_interface.amf-N2-eni.id
  device_index         = 1
}


resource "time_sleep" "sleep-after-amf-N2-eni-attachment" {
depends_on = [aws_network_interface_attachment.amf-N2-eni-attachment]

    create_duration = "10s"
}
 

 #create smf-N4-eni
resource "aws_network_interface" "smf-N4-eni" {
  subnet_id       = aws_subnet.smf-N4-subnet.id
  private_ips     = ["100.64.4.9"]
  security_groups = [aws_security_group.smf-N4-sg.id]
  tags = {
    Name = "smf-N4-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

#Attach to smf-N4-eni to free5gc node
  resource "aws_network_interface_attachment" "smf-N4-eni-attachment" {
  depends_on = [time_sleep.sleep-after-amf-N2-eni-attachment]  
  instance_id          = data.aws_instance._5gcontrolplane-node.id
  network_interface_id = aws_network_interface.smf-N4-eni.id
  device_index         = 2
}

  

##Multus ENI creation and attachments for User-Plane Node:

#Fetch information of the existing eks worker node named "5g-userplane-node"
data "aws_instance" "_5g-userplane-node" {
  depends_on = [module.eks.eks_managed_node_groups]

  filter {
    name   = "tag:Name"
    values = ["5g-userplane-node"]
  }
  
}

#create gnb-N2-eni
resource "aws_network_interface" "gnb-N2-eni" {
  subnet_id       = aws_subnet.ueransim-gnb-N2-subnet.id
  private_ips     = ["100.64.0.9"]
  security_groups = [aws_security_group.gnb-N2-sg.id]
  tags = {
    Name = "gnb-N2-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
    }
  }

  #Attach to gnb-N2-eni to ueransim node
  resource "aws_network_interface_attachment" "gnb-N2-eni-attachment" {
  depends_on = [time_sleep.sleep-after-env-variable]
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.gnb-N2-eni.id
  device_index         = 1
}

resource "time_sleep" "sleep-after-gnb-N2-eni-attachment" {
depends_on = [aws_network_interface_attachment.gnb-N2-eni-attachment]

    create_duration = "10s"
}

 #create gnb-N3-eni
 resource "aws_network_interface" "gnb-N3-eni" {
    subnet_id       = aws_subnet.ueransim-gnb-N3-subnet.id
    private_ips     = ["100.64.2.9"]
    security_groups = [aws_security_group.gnb-N3-sg.id]
    tags = {
      Name = "gnb-N3-eni"
      "node.k8s.amazonaws.com/no_manage" = "true"
    }
  }
  
  #Attach to gnb-N3-eni to ueransim node
    resource "aws_network_interface_attachment" "gnb-N3-eni-attachment" {
    depends_on = [time_sleep.sleep-after-gnb-N2-eni-attachment]  
    instance_id          = data.aws_instance._5g-userplane-node.id
    network_interface_id = aws_network_interface.gnb-N3-eni.id
    device_index         = 2
  }


resource "time_sleep" "sleep-after-gnb-N3-eni-attachment" {
depends_on = [aws_network_interface_attachment.gnb-N3-eni-attachment]

    create_duration = "10s"
} 


#create upf-N3-eni
resource "aws_network_interface" "upf-N3-eni" {
  subnet_id       = aws_subnet.upf-N3-subnet.id
  private_ips     = ["100.64.3.9"]
  security_groups = [aws_security_group.upf-N3-sg.id]
  tags = {
    Name = "upf-N3-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

#Attach to upf-N3-eni to ueransim node
  resource "aws_network_interface_attachment" "upf-N3-eni-attachment" {
  depends_on = [aws_subnet.upf-N3-subnet, time_sleep.sleep-after-gnb-N3-eni-attachment]  
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.upf-N3-eni.id
  device_index         = 3
}


resource "time_sleep" "sleep-after-upf-N3-eni-attachment" {
depends_on = [aws_network_interface_attachment.upf-N3-eni-attachment]

    create_duration = "10s"
} 

#create upf-N4-eni
resource "aws_network_interface" "upf-N4-eni" {
  subnet_id       = aws_subnet.free5gc-upf-N4-subnet.id
  private_ips     = ["100.64.5.9"]
  security_groups = [aws_security_group.upf-N4-sg.id]
  tags = {
    Name = "upf-N4-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
  }

  
  #Attach to upf-N4-eni to ueransim node
  resource "aws_network_interface_attachment" "upf-N4-eni-attachment" {
  depends_on = [aws_subnet.free5gc-upf-N4-subnet, time_sleep.sleep-after-upf-N3-eni-attachment]   
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.upf-N4-eni.id
  device_index         = 4
}


resource "time_sleep" "sleep-after-upf-N4-eni-attachment" {
depends_on = [aws_network_interface_attachment.upf-N4-eni-attachment]

    create_duration = "10s"
} 


#create upf-n6-eni  
resource "aws_network_interface" "upf-N6-eni" {
  subnet_id       = aws_subnet.free5gc-upf-N6-subnet.id
  private_ips     = ["100.64.6.9"]
  security_groups = [aws_security_group.upf-N6-sg.id]
  tags = {
    Name = "upf-N6-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

#Attach to upf-N6-eni to ueransim node
  resource "aws_network_interface_attachment" "upf-N6-eni-attachment" {
  depends_on = [aws_subnet.free5gc-upf-N6-subnet, time_sleep.sleep-after-upf-N4-eni-attachment]   
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.upf-N6-eni.id
  device_index         = 5
}



##Create security groups for multus eni interfaces
  
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


##Create security group rules to allow traffic between designated multus NICs:


#create rule allow egress from gNB N2 interface
resource "aws_security_group_rule" "allow-egress-from-gnb-to-amf" {
  type                     = "egress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.gnb-N2-sg.id
  source_security_group_id = aws_security_group.amf-N2-sg.id
}

#create rule allow ingress to AMF N2 interface
resource "aws_security_group_rule" "allow-ingress-to-amf-from-gnb" {
  type                     = "ingress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.amf-N2-sg.id
  source_security_group_id = aws_security_group.gnb-N2-sg.id
}

#create rule allow egress from AMF N2 interface
resource "aws_security_group_rule" "allow-egress-from-amf-to-gnb" {
  type                     = "egress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.amf-N2-sg.id
  source_security_group_id = aws_security_group.gnb-N2-sg.id
}

#create rule allow ingress to gNB N2 interface
resource "aws_security_group_rule" "allow-ingress-to-gnb-from-amf" {
  type                     = "ingress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.gnb-N2-sg.id
  source_security_group_id = aws_security_group.amf-N2-sg.id
}

#create rule allow egress from gNB N3 interface
resource "aws_security_group_rule" "allow-egress-from-gnb-to-upf" {
  type                     = "egress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.gnb-N3-sg.id
  source_security_group_id = aws_security_group.upf-N3-sg.id
}


#create rule allow ingress to UPF N3 interface
resource "aws_security_group_rule" "allow-ingress-to-upf-from-gnb" {
  type                     = "ingress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.upf-N3-sg.id
  source_security_group_id = aws_security_group.gnb-N3-sg.id
}



#create rule allow egress from UPF N3 interface
resource "aws_security_group_rule" "allow-egress-from-upf-to-gnb" {
  type                     = "egress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.upf-N3-sg.id
  source_security_group_id = aws_security_group.gnb-N3-sg.id
}

#create rule allow ingress to gNB N3 interface
resource "aws_security_group_rule" "allow-ingress-to-gnb-from-upf" {
  type                     = "ingress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.gnb-N3-sg.id
  source_security_group_id = aws_security_group.upf-N3-sg.id
}


#create rule allow egress from SMF N4 interface
resource "aws_security_group_rule" "allow-egress-from-smf-to-upf" {
  type                     = "egress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.smf-N4-sg.id
  source_security_group_id = aws_security_group.upf-N4-sg.id
}

#create rule allow ingress to UPF N4 interface
resource "aws_security_group_rule" "allow-ingress-to-upf-from-smf" {
  type                     = "ingress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.upf-N4-sg.id
  source_security_group_id = aws_security_group.smf-N4-sg.id
}

#create rule allow egress from UPF N4 interface
resource "aws_security_group_rule" "allow-egress-from-upf-to-smf" {
  type                     = "egress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.upf-N4-sg.id
  source_security_group_id = aws_security_group.smf-N4-sg.id
}


#create rule allow ingress to SMF N4 interface
resource "aws_security_group_rule" "allow-ingress-to-smf-from-upf" {
  type                     = "ingress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.smf-N4-sg.id
  source_security_group_id = aws_security_group.upf-N4-sg.id
}


#create rule allow egress from UPF N6 interface
resource "aws_security_group_rule" "allow-egress-from-upf-to-DN" {
  type                     = "egress"
  to_port                  = 0
  protocol                 = "-1"
  from_port                = 0
  security_group_id        = aws_security_group.upf-N6-sg.id
  cidr_blocks               = ["0.0.0.0/0"]
}



