#Multus Subnets for Control-Plane Node:


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
resource "aws_ec2_subnet_cidr_reservation" "amf-N2-subnet" {
  cidr_block       = "100.64.1.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.amf-N2-subnet.id
}





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
resource "aws_ec2_subnet_cidr_reservation" "smf-N4-subnet" {
  cidr_block       = "100.64.4.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.smf-N4-subnet.id
}


###############################################

#Multus Subnets for User-Plane Node:

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
resource "aws_ec2_subnet_cidr_reservation" "upf-N6-subnet" {
  cidr_block       = "100.64.6.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.free5gc-upf-N6-subnet.id
}



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
resource "aws_ec2_subnet_cidr_reservation" "upf-N4-subnet" {
  cidr_block       = "100.64.5.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.free5gc-upf-N4-subnet.id
}


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
resource "aws_ec2_subnet_cidr_reservation" "gnb-N3-subnet" {
  cidr_block       = "100.64.2.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.ueransim-gnb-N3-subnet.id
}

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
resource "aws_ec2_subnet_cidr_reservation" "upf-N3-subnet" {
  cidr_block       = "100.64.3.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.upf-N3-subnet.id
}




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
resource "aws_ec2_subnet_cidr_reservation" "gnb-N2-subnet" {
  cidr_block       = "100.64.0.0/28"
  reservation_type = "explicit"
  subnet_id        = aws_subnet.ueransim-gnb-N2-subnet.id
}
