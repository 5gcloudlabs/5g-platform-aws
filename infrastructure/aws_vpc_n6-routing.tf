
#create new route table for UPF n6 interface
resource "aws_route_table" "n6-route-table" {
  vpc_id = module.vpc.vpc_id

#default route to existing vpc nat-gw for internet reacheability
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = module.vpc.natgw_ids[0]
  }

  

  tags = {
    Name = "n6-route-table"
  }
}

#associate route table with upf n6 interface subnet
resource "aws_route_table_association" "n6-rt-subnet-association" {
  subnet_id      = aws_subnet.free5gc-upf-N6-subnet.id
  route_table_id = aws_route_table.n6-route-table.id
}