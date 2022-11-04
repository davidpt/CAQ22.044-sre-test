output "Network" {
  value = {
    "VPC"     = aws_vpc.my_vpc
    "SUBNETS" = aws_subnet.my_subnet
    # "NAT GW" = aws_nat_gateway.my-nat-gw
    # "IGW" = aws_internet_gateway.my-igw
    # "RT for public subnets" = aws_route_table.rt_public_sn
    # "RT for private subnets" = aws_route_table.rt_private_sn
    # "RT assoc. with public subnets" = aws_route_table_association.my_public_rt_association
    # "RT assoc. with private subnets" = aws_route_table_association.my_private_rt_association
    # "NAT GW IP" = aws_eip.my-eip-natgw.public_ip
  }
}
