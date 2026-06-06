variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro" # Free-tier eligible instance type
  description = "The hardware sizing SKU profile"
}
