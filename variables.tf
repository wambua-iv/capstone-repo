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
  default     = "t3.micro"
  description = "The hardware sizing SKU profile"
}

variable "azure_vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "azure_public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "azure_private_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "azure_instance_type" {
  type    = string
  default = "Standard_D2ls_v7"
}

variable "ssh_public_key" {
  type = string
  
}