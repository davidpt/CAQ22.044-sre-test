packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "Name" {
  type    = string
}

locals {
  timestamp = formatdate("YYYY-MM-DD", timestamp())
}

source "amazon-ebs" "ubuntu" {
  ami_name      = var.Name
  instance_type = "t2.micro"
  region        = "eu-west-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "my-packer-build"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2",
      "sudo chmod 647 /var/www/html/index.html",
      "echo \"Hello World at ${local.timestamp}\" > /var/www/html/index.html",
      "sudo chmod 644 /var/www/html/index.html"
    ]
  }

  post-processor "manifest" {}
}
