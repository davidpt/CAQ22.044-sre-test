# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

locals {
  num_half_subnets = length(aws_subnet.my_subnet) / 2
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.Network_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge({ Name = join("-", [var.Name, "vpc"]) }, var.Tags)
}

#public subnets are created first and private second
resource "aws_subnet" "my_subnet" {
  count             = var.N_subnets
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.Network_CIDR, 4, count.index)
  availability_zone = "eu-west-1a"

  tags = merge({ Name = join("-", [var.Name, "subnet", count.index + 1]) }, var.Tags)
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge({ Name = join("-", [var.Name, "internet-gateway"]) }, var.Tags)
}

resource "aws_eip" "my-eip-natgw" {
  vpc        = true
  depends_on = [aws_internet_gateway.my-igw]
}

resource "aws_nat_gateway" "my-nat-gw" {
  #same logic for the 0 index
  #as recommended by the documentation, the association of the nat gw with an eip is done through the allocation_id:
  #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
  allocation_id     = aws_eip.my-eip-natgw.id
  connectivity_type = "public"
  #we will place our nat gateway inside the first public subnet. Its index will always be 0
  #and we know at least one will always be created
  subnet_id = aws_subnet.my_subnet[0].id

  tags = merge({ Name = join("-", [var.Name, "nat-gateway"]) }, var.Tags)
}

#route table with all destinations to the igw
resource "aws_route_table" "rt_public_sn" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.my-igw.id
  }

  tags = merge({ Name = join("-", [var.Name, "rt-public"]) }, var.Tags)
}

#associate the previous route table with our public subnets
resource "aws_route_table_association" "my_public_rt_association" {
  #only half the subnets are public and thus have their traffic routed to the internet gateway
  #this makes them able to access the internet and being accessed from the internet
  count = local.num_half_subnets

  subnet_id      = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.rt_public_sn.id
}

#route table with all destinations to the nat gw
resource "aws_route_table" "rt_private_sn" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat-gw.id
  }

  #an interface that is part of a NAT gateway cannot be the next hop for an IPv6 destination CIDR
  #block outside the CIDR range 64:ff9b::/96 or IPv6 prefix list

  # route {
  #   ipv6_cidr_block = "::/0"
  #   gateway_id      = aws_nat_gateway.my-nat-gw.id
  # }

  tags = merge({ Name = join("-", [var.Name, "rt-private"]) }, var.Tags)
}

#associate the previous route table with our private subnets
resource "aws_route_table_association" "my_private_rt_association" {
  #only half the subnets private. They access the internet through the NAT gateway placed in a public subnet
  #but they can not be accessed from the internet
  count = local.num_half_subnets

  subnet_id      = aws_subnet.my_subnet[local.num_half_subnets + count.index].id
  route_table_id = aws_route_table.rt_private_sn.id
}
