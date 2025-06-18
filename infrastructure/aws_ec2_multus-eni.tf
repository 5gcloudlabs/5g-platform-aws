#Multus nics creation and attachments for Control-Plane Node:

#Fetch information of the existing eks worker node named "5g-controlplane-node"
data "aws_instance" "_5gcontrolplane-node" {
  depends_on = [module.eks.eks_managed_node_groups]

  filter {
    name   = "tag:Name"
    values = ["5g-controlplane-node"]
  }
  
}

#create amf-N2-nic
resource "aws_network_interface" "amf-N2-nic" {
  subnet_id       = aws_subnet.amf-N2-subnet.id
  private_ips     = ["100.64.1.9"]
  security_groups = [aws_security_group.amf-N2-sg.id]
  tags = {
    Name = "amf-N2-nic"
    "node.k8s.amazonaws.com/no_manage" = "true"
    }
  }

  #Attach to amf-N2-nic to free5gc node
  resource "aws_network_interface_attachment" "amf-N2-nic-attachment" {
  depends_on = [time_sleep.sleep-after-env-variable]
  instance_id          = data.aws_instance._5gcontrolplane-node.id
  network_interface_id = aws_network_interface.amf-N2-nic.id
  device_index         = 1
}


resource "time_sleep" "sleep-after-amf-N2-nic-attachment" {
depends_on = [aws_network_interface_attachment.amf-N2-nic-attachment]

    create_duration = "10s"
}
 

 #create smf-N4-nic
resource "aws_network_interface" "smf-N4-nic" {
  subnet_id       = aws_subnet.smf-N4-subnet.id
  private_ips     = ["100.64.4.9"]
  security_groups = [aws_security_group.smf-N4-sg.id]
  tags = {
    Name = "smf-N4-nic"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

#Attach to smf-N4-nic to free5gc node
  resource "aws_network_interface_attachment" "smf-N4-nic-attachment" {
  depends_on = [time_sleep.sleep-after-amf-N2-nic-attachment]  
  instance_id          = data.aws_instance._5gcontrolplane-node.id
  network_interface_id = aws_network_interface.smf-N4-nic.id
  device_index         = 2
}

  


###############################################

#Multus ENI creation and attachments for User-Plane Node:

#Fetch information of the existing eks worker node named "5g-userplane-node"
data "aws_instance" "_5g-userplane-node" {
  depends_on = [module.eks.eks_managed_node_groups]

  filter {
    name   = "tag:Name"
    values = ["5g-userplane-node"]
  }
  
}

#create gnb-N2-nic
resource "aws_network_interface" "gnb-N2-nic" {
  subnet_id       = aws_subnet.ueransim-gnb-N2-subnet.id
  private_ips     = ["100.64.0.9"]
  security_groups = [aws_security_group.gnb-N2-sg.id]
  tags = {
    Name = "gnb-N2-nic"
    "node.k8s.amazonaws.com/no_manage" = "true"
    }
  }

  #Attach to gnb-N2-nic to ueransim node
  resource "aws_network_interface_attachment" "gnb-N2-nic-attachment" {
  depends_on = [time_sleep.sleep-after-env-variable]
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.gnb-N2-nic.id
  device_index         = 1
}

resource "time_sleep" "sleep-after-gnb-N2-nic-attachment" {
depends_on = [aws_network_interface_attachment.gnb-N2-nic-attachment]

    create_duration = "10s"
}

 #create gnb-N3-nic
 resource "aws_network_interface" "gnb-N3-nic" {
    subnet_id       = aws_subnet.ueransim-gnb-N3-subnet.id
    private_ips     = ["100.64.2.9"]
    security_groups = [aws_security_group.gnb-N3-sg.id]
    tags = {
      Name = "gnb-N3-nic"
      "node.k8s.amazonaws.com/no_manage" = "true"
    }
  }
  
  #Attach to gnb-N3-nic to ueransim node
    resource "aws_network_interface_attachment" "gnb-N3-nic-attachment" {
    depends_on = [time_sleep.sleep-after-gnb-N2-nic-attachment]  
    instance_id          = data.aws_instance._5g-userplane-node.id
    network_interface_id = aws_network_interface.gnb-N3-nic.id
    device_index         = 2
  }


resource "time_sleep" "sleep-after-gnb-N3-nic-attachment" {
depends_on = [aws_network_interface_attachment.gnb-N3-nic-attachment]

    create_duration = "10s"
} 


#create upf-N3-nic
resource "aws_network_interface" "upf-N3-nic" {
  subnet_id       = aws_subnet.upf-N3-subnet.id
  private_ips     = ["100.64.3.9"]
  security_groups = [aws_security_group.upf-N3-sg.id]
  tags = {
    Name = "upf-N3-nic"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

#Attach to upf-N3-nic to ueransim node
  resource "aws_network_interface_attachment" "upf-N3-nic-attachment" {
  depends_on = [aws_subnet.upf-N3-subnet, time_sleep.sleep-after-gnb-N3-nic-attachment]  
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.upf-N3-nic.id
  device_index         = 3
}


resource "time_sleep" "sleep-after-upf-N3-nic-attachment" {
depends_on = [aws_network_interface_attachment.upf-N3-nic-attachment]

    create_duration = "10s"
} 

#create upf-N4-nic
resource "aws_network_interface" "upf-N4-nic" {
  subnet_id       = aws_subnet.free5gc-upf-N4-subnet.id
  private_ips     = ["100.64.5.9"]
  security_groups = [aws_security_group.upf-N4-sg.id]
  tags = {
    Name = "upf-N4-nic"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
  }

  
  #Attach to upf-N4-nic to ueransim node
  resource "aws_network_interface_attachment" "upf-N4-nic-attachment" {
  depends_on = [aws_subnet.free5gc-upf-N4-subnet, time_sleep.sleep-after-upf-N3-nic-attachment]   
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.upf-N4-nic.id
  device_index         = 4
}


resource "time_sleep" "sleep-after-upf-N4-nic-attachment" {
depends_on = [aws_network_interface_attachment.upf-N4-nic-attachment]

    create_duration = "10s"
} 


#create upf-n6-nic  
resource "aws_network_interface" "upf-N6-nic" {
  subnet_id       = aws_subnet.free5gc-upf-N6-subnet.id
  private_ips     = ["100.64.6.9"]
  security_groups = [aws_security_group.upf-N6-sg.id]
  tags = {
    Name = "upf-N6-nic"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

#Attach to upf-N6-nic to ueransim node
  resource "aws_network_interface_attachment" "upf-N6-nic-attachment" {
  depends_on = [aws_subnet.free5gc-upf-N6-subnet, time_sleep.sleep-after-upf-N4-nic-attachment]   
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.upf-N6-nic.id
  device_index         = 5
}

  
