#Note: The mask should never be above /26. If above, there is no space for hosts if 6 subnets are required
variable "Network" {
  type        = any
  description = "To set where the instances must be attached"
}

# variable "Image" {
#   type        = module.Golden_Image.output.Manifest
#   description = "Set the total subnets to create inside the VPC"
# }

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
