output "Private_Instances_IP_addresses" {
  value = aws_instance.private-host[*].private_ip
}

output "Bastion_Host_IP_address" {
  value = aws_eip.bastion-host-eip.public_ip
}

#not implemented
output "Load_balancer_HTTP_DNS" {
  value = "Load_balancer_HTTP_DNS"
}

output "SSH_key_Content" {
  value = tls_private_key.key.private_key_pem
}

output "Usernames" {
  #it works because all AMIs selected use the same username but this does not fulfill the goal of the exercise
  value = "ubuntu"
}
