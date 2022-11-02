output "Network" {
  value = {
    "VPC"     = aws_vpc.my_vpc
    "SUBNETS" = aws_subnet.my_subnet
    "NAT GW" = aws_nat_gateway.my-nat-gw
    "IGW" = aws_internet_gateway.my-igw
    "RT for public subnets" = aws_route_table.rt_public_sn
    "RT for private subnets" = aws_route_table.rt_private_sn
    "RT assoc. with public subnets" = aws_route_table_association.my_public_rt_association
    "RT assoc. with private subnets" = aws_route_table_association.my_private_rt_association
    "Security group" = aws_security_group.allow_web
    "EIP for IGW" = aws_eip.my-eip-igw
    "EIP for NAT GW" = aws_eip.my-eip-natgw
  }
}
