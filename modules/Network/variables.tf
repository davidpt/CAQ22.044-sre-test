#Note: The mask should never be above /26. If above, there is no space for hosts if 6 subnets are required
variable "Network_CIDR" {
  type        = string
  description = "Set the IP address configuration of the network resources inside the VPC"
}

variable "N_subnets" {
  type        = number
  description = "Set the total subnets to create inside the VPC"

  validation {
    #The number is even if the remainder of dividing by 2 is 0
    condition     = var.N_subnets > 0 && var.N_subnets <= 6 && var.N_subnets % 2 == 0
    error_message = "The number of subnets must be even and between 2 and 6"
  }
}

variable "Name" {
  type        = string
  description = "Set the name value on Tags or resources field if the resource supports or requires it"
}

variable "Tags" {
  type        = map(string)
  description = "Set tags on the resources that support it"
  #Optional
  default = null
}
