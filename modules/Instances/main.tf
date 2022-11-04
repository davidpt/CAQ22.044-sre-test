# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

locals {
  num_half_subnets = length(var.Network["SUBNETS"]) / 2
  golden_image_AMI = regex("^[^:]*:(.*)$", var.Image.builds[0].artifact_id)[0] # AMI originated from the packer build
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my-kp" {
  key_name   = "golden-ticket"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_eip" "bastion-host-eip" {
  instance = aws_instance.bastion-host.id
  vpc      = true
}

resource "aws_instance" "bastion-host" {
  instance_type = "t2.micro"
  ami           = "ami-096800910c1b781ba" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  #first subnet is a public subnet and always exists
  subnet_id               = var.Network["SUBNETS"][0].id
  security_groups         = [aws_security_group.sg_bastion_host.id]
  key_name                = aws_key_pair.my-kp.key_name
  disable_api_termination = false
  # ebs_optimized           = false
  root_block_device {
    volume_size = "10"
  }

  tags = merge({ Name = join("-", [var.Name, "bastion-host"]) }, var.Tags)
}

#create an instance for every private subnet
resource "aws_instance" "private-host" {
  #half of the networks are private
  count                   = local.num_half_subnets
  instance_type           = "t2.micro"
  ami                     = local.golden_image_AMI
  subnet_id               = var.Network["SUBNETS"][local.num_half_subnets + count.index].id
  security_groups         = [aws_security_group.sg_private_host.id]
  key_name                = aws_key_pair.my-kp.key_name
  disable_api_termination = false
  # ebs_optimized           = false
  root_block_device {
    volume_size = "10"
  }

  tags = merge({ Name = join("-", [var.Name, "private-host", count.index + 1]) }, var.Tags)
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
  #another url is: https://api.ipify.org
}

resource "aws_security_group" "sg_bastion_host" {
  #security group name
  name        = join("-", [var.Name, "sg-bastion-host"])
  description = "Allow ssh connection to bastion host"
  vpc_id      = var.Network["VPC"].id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #https://stackoverflow.com/questions/46763287/i-want-to-identify-the-public-ip-of-the-terraform-execution-environment-and-add
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({ Name = join("-", [var.Name, "sec-group-bastion-host"]) }, var.Tags)
}

resource "aws_security_group" "sg_private_host" {
  #security group name
  name        = join("-", [var.Name, "sg-private-host"])
  description = "Allow ssh connection from bastion host"
  vpc_id      = var.Network["VPC"].id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-host.private_ip}/32"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({ Name = join("-", [var.Name, "sec-group-private-host"]) }, var.Tags)
}
