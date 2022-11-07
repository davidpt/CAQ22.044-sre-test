output "Private_Instances_IP_addresses" {
  value = aws_instance.private-host[*].private_ip
}

output "Bastion_Host_IP_address" {
  value = aws_eip.bastion-host-eip.public_ip
}

output "Load_balancer_HTTP_DNS" {
  #acessing the 0 index due to the count parameter used
  value = local.create_load_balancer ? aws_lb.load-balancer[0].dns_name : "Creating an ALB requires two private subnets in distinct AZs"
}

output "SSH_key_content" {
  value = tls_private_key.key.private_key_pem
}

output "Usernames" {
  #The same username is used between the bastion host and the golden image used in the private instances
  value = var.Image.builds[0].name
}
