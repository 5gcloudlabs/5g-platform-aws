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



