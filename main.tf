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

module "network" {
  source       = "./modules/Network"
  Network_CIDR = var.network_cidr
  N_subnets    = var.num_of_subnets
  Name         = var.name
  Tags         = var.tags
}

output "network_output" {
  value = module.network.Network
}
