variable "vpc_id" {
  description = "ID of VPC to house Consul instance."
  type        = string
}

variable "subnet_id" {
  description = "ID of subnet to house Consul instance."
  type        = string
}

variable "key_pair" {
  description = "Name of AWS key pair used to authenticate into Consul instance."
  default     = ""
  type        = string
}

variable "name_prefix" {
  description = "Prefix prepended to names of generated resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to generated resources."
  default     = {}
  type        = map
}

variable "allow_from" {
  description = "IP CIDR block of allowed traffic for Consul security groups."
  type        = string
}