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

output "SSH_key_content" {
  value = tls_private_key.key.private_key_pem
}

output "Usernames" {
  #The same username is used between the bastion host and the golden image used in the private instances
  value = var.Image.builds[0].name
}
