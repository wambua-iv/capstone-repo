terraform {

}

# provider "aws" {
#   region = "eu-west-2"
# }

# data "aws_ami" "ubuntu" {
#     most_recent = true
#   owners      = ["099720109477"]
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.capstone_vpc.id
#   tags   = { Name = "capstone-igw" }
# }

# resource "aws_vpc" "capstone_vpc" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Name        = "capstone-foundation-vpc"
#     Environment = "dev"
#     Owner       = "capstone-architect"
#   }
# }

# resource "aws_subnet" "public_web" {
#   vpc_id                  = aws_vpc.capstone_vpc.id
#   cidr_block              = var.public_subnet_cidr
#   map_public_ip_on_launch = false
#   tags                    = { Name = "capstone-public-web-subnet" }
# }

# resource "aws_subnet" "private_app" {
#   vpc_id            = aws_vpc.capstone_vpc.id
#   cidr_block        = var.private_subnet_cidr
#   tags              = { Name = "capstone-private-app-subnet" }
# }

# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.capstone_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   tags = { Name = "capstone-public-rt" }
# }

# resource "aws_route_table_association" "public_assoc" {
#   subnet_id      = aws_subnet.public_web.id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_security_group" "web_sg" {
#   name   = "capstone-web-sg"
#   vpc_id = aws_vpc.capstone_vpc.id

#   ingress {
#     description = "Allow HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "app_sg" {
#   name        = "capstone-app-sg"
#   description = "Isolate application tier from direct public exposure"
#   vpc_id      = aws_vpc.capstone_vpc.id

#   ingress {
#     description     = "Allow backend ports strictly from Web tier security group"
#     from_port       = 5670
#     to_port         = 5670
#     protocol        = "tcp"
#     security_groups = [aws_security_group.web_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_instance" "web_server" {
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.public_web.id
#   vpc_security_group_ids = [aws_security_group.web_sg.id]

#   tags = {
#     Name        = "capstone-public-web-vm"
#     Environment = "dev"
#     Role        = "Web-Tier"
#     Cost-Center = "capstone-101"
#     Lifecycle   = "ephemeral"
#   }
# }

# resource "aws_instance" "app_server" {
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.private_app.id
#   vpc_security_group_ids = [aws_security_group.app_sg.id]

#   tags = {
#     Name        = "capstone-private-app-vm"
#     Environment = "dev"
#     Role        = "App-Tier"
#     Cost-Center = "capstone-101"
#     Lifecycle   = "ephemeral"
#   }
# }



provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "capstone_rg" {
  name     = "capstone-foundation"
  location = "eastus" 
}


resource "azurerm_virtual_network" "capstone_vnet" {
  name                = "capstone-foundation-vnet"
  address_space       = [var.azure_vpc_cidr]
  location            = azurerm_resource_group.capstone_rg.location
  resource_group_name = azurerm_resource_group.capstone_rg.name

  tags = {
    Environment = "dev"
    Owner       = "capstone-architect"
  }
}

resource "azurerm_subnet" "public_web" {
  name                 = "capstone-public-web-subnet"
  resource_group_name  = azurerm_resource_group.capstone_rg.name
  virtual_network_name = azurerm_virtual_network.capstone_vnet.name
  address_prefixes     = [var.azure_public_subnet_cidr]
}

resource "azurerm_subnet" "private_app" {
  name                 = "capstone-private-app-subnet"
  resource_group_name  = azurerm_resource_group.capstone_rg.name
  virtual_network_name = azurerm_virtual_network.capstone_vnet.name
  address_prefixes     = [var.azure_private_subnet_cidr]
}

resource "azurerm_network_security_group" "web_nsg" {
  name                = "capstone-web-nsg"
  location            = azurerm_resource_group.capstone_rg.location
  resource_group_name = azurerm_resource_group.capstone_rg.name

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "capstone-web-app-nsg"
  location            = azurerm_resource_group.capstone_rg.location
  resource_group_name = azurerm_resource_group.capstone_rg.name

  security_rule {
    name                       = "AllowBackendFromWebSubnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5670"
    source_address_prefix      = var.azure_public_subnet_cidr 
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyDirectInternetInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}


resource "azurerm_subnet_network_security_group_association" "web_assoc" {
  subnet_id                 = azurerm_subnet.public_web.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = azurerm_subnet.private_app.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_public_ip" "web_pip" {
  name                = "capstone-web-pip"
  location            = azurerm_resource_group.capstone_rg.location
  resource_group_name = azurerm_resource_group.capstone_rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "web_nic" {
  name                = "capstone-web-nic"
  location            = azurerm_resource_group.capstone_rg.location
  resource_group_name = azurerm_resource_group.capstone_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_pip.id
  }
}

resource "azurerm_network_interface" "app_nic" {
  name                = "capstone-app-nic"
  location            = azurerm_resource_group.capstone_rg.location
  resource_group_name = azurerm_resource_group.capstone_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_app.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "web_server" {
  name                = "capstone-public-web-vm"
  resource_group_name = azurerm_resource_group.capstone_rg.name
  location            = azurerm_resource_group.capstone_rg.location
  size                = var.azure_instance_type
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.web_nic.id,
  ]

  
  admin_password                  = "CapstoneP@ssw0rd123!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts" 
    sku       = "server"           
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" 
  }

  tags = {
    Name        = "capstone-public-web-vm"
    Environment = "dev"
    Role        = "Web-Tier"
    Cost-Center = "capstone-101"
    Lifecycle   = "ephemeral"
  }
}

resource "azurerm_linux_virtual_machine" "app_server" {
  name                = "capstone-private-app-vm"
  resource_group_name = azurerm_resource_group.capstone_rg.name
  location            = azurerm_resource_group.capstone_rg.location
  size                = var.azure_instance_type
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.app_nic.id,
  ]

  admin_password                  = "CapstoneP@ssw0rd123!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts" 
    sku       = "server"           
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    Name        = "capstone-private-app-vm"
    Environment = "dev"
    Role        = "App-Tier"
    Cost-Center = "capstone-101"
    Lifecycle   = "ephemeral"
  }
}
