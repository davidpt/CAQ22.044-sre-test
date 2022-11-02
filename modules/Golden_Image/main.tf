resource "aws_instance" "my-web-server" {
  count             = length(aws_subnet.my_subnet) / 2
  ami               = "ami-096800910c1b781ba"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-1a"
  key_name          = aws_key_pair.my-kp.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.my_nic[count.index].id
  }

  user_data = <<-EOL
  #!/bin/bash -xe
  touch test.txt 
  EOL

  tags = merge({ Name = join("-", [var.Name, "ubuntu-os", count.index]) }, var.Tags)
}

# output "web_server_public_ip" {
#   value = aws_eip.one.public_ip
# }
