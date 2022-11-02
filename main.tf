variable "network_cidr" {
  description = "Used to set the CIDR of the VPC"
}
variable "num_of_subnets" {
  description = "Number of subnets to be created in the VPC"
}
variable "name" {
  description = "Used to set the CIDR of the VPC"
}
variable "tags" {
  description = "Tags to be set on resources that support them"
}

module "Network" {
  source       = "./modules/Network"
  Network_CIDR = var.network_cidr
  N_subnets    = var.num_of_subnets
  Name         = var.name
  Tags         = var.tags
}

# module "Golden_Image" {
#   source       = "./modules/Golden_Image"
# }

module "Instances" {
  source  = "./modules/Instances"
  Network = module.Network.Network
  # Image = module.Golden_Image.output.Manifest
  Name = var.name
  Tags = var.tags
}

output "Private_instances_IP_addresses" {
  value = "Private_instances_IP_addresses"

  # value {
  #   "instance1"     = module.network.Network
  # }
}

output "Bastion_Host_IP" {
  value = "Bastion_Host_IP"
}

output "SSH_key_content" {
  value = "SSH_key_content"
}

output "Load_balancer_HTTP_Content" {
  value = "Load_balancer_HTTP_Content"
}

output "Usernames" {
  value = "Usernames"
}
