# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.Network_CIDR

  tags = merge({ Name = join("-", [var.Name, "vpc"]) }, var.Tags)
}

resource "aws_subnet" "my_subnet" {
  count             = var.N_subnets
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.Network_CIDR, 4, "${count.index}")
  availability_zone = "eu-west-1a"

  tags = merge({ Name = join("-", [var.Name, "subnet", "${count.index}"]) }, var.Tags)
}

# resource "aws_internet_gateway" "my_gateway" {
#   vpc_id = aws_vpc.my_vpc.id

#   tags = {
#     Name = "my-gateway"
#   }
# }

# resource "aws_route_table" "my_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_gateway.id
#   }

#   route {
#     ipv6_cidr_block        = "::/0"
#     gateway_id = aws_internet_gateway.my_gateway.id
#   }

#   tags = {
#     Name = "my-route-table"
#   }
# }

# resource "aws_subnet" "my_subnet" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "us-east-1a"

#   tags = {
#     Name = "my-subnet"
#   }
# }

# resource "aws_route_table_association" "my_rt_association" {
#   subnet_id      = aws_subnet.my_subnet.id
#   route_table_id = aws_route_table.my_route_table.id
# }

# resource "aws_security_group" "allow_web" {
#   name        = "allow-web-traffic"
#   description = "Allow web traffic"
#   vpc_id      = aws_vpc.my_vpc.id

#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow-web"
#   }
# }

# resource "aws_network_interface" "my_nic" {
#   subnet_id       = aws_subnet.my_subnet.id
#   private_ips     = ["10.0.1.50"]
#   security_groups = [aws_security_group.allow_web.id]
# }

# resource "aws_eip" "one" {
#   vpc                       = true
#   network_interface         = aws_network_interface.my_nic.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on                = [aws_internet_gateway.my_gateway]
# }

# resource "aws_instance" "my-web-server" {
#   ami               = "ami-08c40ec9ead489470"
#   instance_type     = "t2.micro"
#   availability_zone = "us-east-1a"
#   key_name          = "my-key"
#   network_interface {
#     device_index = 0
#     network_interface_id = aws_network_interface.my_nic.id
#   }

#   user_data = <<EOF
#               #!/bin/bash
#               sudo apt update -y
#               sudo apt install apache2 -y
#               sudo systemctl start apache2
#               sudo bash -c 'echo your very first web server > /var/www/html/index.html'
#               EOF

#   tags = {
#     Name = "ubuntu"
#   }
# }

# output "web_server_public_ip" {
#   value = aws_eip.one.public_ip
# }
