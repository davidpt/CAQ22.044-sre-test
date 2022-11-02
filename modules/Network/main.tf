# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.Network_CIDR

  tags = merge({ Name = join("-", [var.Name, "vpc"]) }, var.Tags)
}

#public subnets are created first and private second
resource "aws_subnet" "my_subnet" {
  count             = var.N_subnets
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.Network_CIDR, 4, count.index)
  availability_zone = "eu-west-1a"

  tags = merge({ Name = join("-", [var.Name, "subnet", count.index + 1]) }, var.Tags)
}

resource "aws_nat_gateway" "my-nat-gw" {
  #same logic for the 0 index. We want the elastic ip of the first public subnet
  allocation_id = aws_eip.my-eip-natgw.id
  connectivity_type = "public"
  #we will place our nat gateway inside the first public subnet. Its index will always be 0
  #and we know at least one will always be created
  subnet_id     = aws_subnet.my_subnet[0].id

  tags = merge({ Name = join("-", [var.Name, "nat-gateway"]) }, var.Tags)
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge({ Name = join("-", [var.Name, "internet-gateway"]) }, var.Tags)
}

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

resource "aws_route_table_association" "my_public_rt_association" {
  #only half the subnets are public and thus have their traffic routed to the internet gateway
  #this makes them able to access the internet and being accessed from the internet
  count = length(aws_subnet.my_subnet) / 2

  subnet_id      = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.rt_public_sn.id
}

resource "aws_route_table" "rt_private_sn" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat-gw.id
  }

  # route {
  #   ipv6_cidr_block = "::/0"
  #   gateway_id      = aws_internet_gateway.my-igw.id
  # }

  tags = merge({ Name = join("-", [var.Name, "rt-private"]) }, var.Tags)
}

resource "aws_route_table_association" "my_private_rt_association" {
  #only half the subnets private. They access the internet through the NAT gateway placed in a public subnet
  #but they can not be accessed from the internet
  count = length(aws_subnet.my_subnet) / 2

  subnet_id      = aws_subnet.my_subnet[length(aws_subnet.my_subnet) / 2 + count.index].id
  route_table_id = aws_route_table.rt_private_sn.id
}

resource "aws_security_group" "allow_web" {
  #security group name
  name        = join("-", [var.Name, "allow-web-traffic"])
  description = "Allow web traffic and ssh connection"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({ Name = join("-", [var.Name, "sec-group-allow-web"]) }, var.Tags)
}

resource "aws_network_interface" "my_nic" {
  count = length(aws_subnet.my_subnet) / 2

  subnet_id       = aws_subnet.my_subnet[count.index].id
  security_groups = [aws_security_group.allow_web.id]

  tags = merge({ Name = join("-", [var.Name, "my-nic"]) }, var.Tags)
}

#this could be declared in the beginning since it's a dependency for creating the nat gateway
#but terraform knows this and solves this by creating it first
resource "aws_eip" "my-eip-igw" {
  count             = length(aws_subnet.my_subnet) / 2
  vpc               = true
  network_interface = aws_network_interface.my_nic[count.index].id
  #associate_with_private_ip = aws_network_interface.my_nic.private_ip
  depends_on = [aws_internet_gateway.my-igw]
}

resource "aws_eip" "my-eip-natgw" {
  vpc               = true
  # network_interface = aws_network_interface.my_nic[count.index].id
  #associate_with_private_ip = aws_network_interface.my_nic.private_ip
  depends_on = [aws_internet_gateway.my-igw]
}
