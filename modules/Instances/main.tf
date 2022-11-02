# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

resource "aws_key_pair" "my-kp" {
  key_name   = "golden-ticket"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbJKZ01RBPPrMNCjmPeaQkgbZ2OAy6KWwR3K3s7D+NWHde4TCwFFRS9mhPOer9QKAP605hEzGQMilsCO46uXebKd4T5IW0B+Zo28FPaRZP5DPSKXs6X8VzU7nlFidGqrVhCFseXWks8904MF0G9q6gTNIGR08WktDdRk3VLiXgjN/CBEvnDODUsv+wFLNLemS1PPnnOR3BKYucf7nu2S92AK5bFKFxHdER4db9fddM/azzbIODmJSYyA10qgzAmIsFjn2CGcyUJGqvk4kA7oNtoom72H49bExW4skFmGDfcD0r76k89mx2CvDIdincbEBFNWApJkzxu6OK7ekNcgON imported-openssh-key"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
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
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
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
