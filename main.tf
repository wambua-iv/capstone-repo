terraform {

}

provider "aws" {
  region = "eu-west-2"
}

data "aws_ami" "ubuntu" {
    most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.capstone_vpc.id
  tags   = { Name = "capstone-igw" }
}

resource "aws_vpc" "capstone_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "capstone-foundation-vpc"
    Environment = "dev"
    Owner       = "capstone-architect"
  }
}

resource "aws_subnet" "public_web" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2 a"
  tags                    = { Name = "capstone-public-web-subnet" }
}

resource "aws_subnet" "private_app" {
  vpc_id            = aws_vpc.capstone_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-west-2 a"
  tags              = { Name = "capstone-private-app-subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.capstone_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "capstone-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_web.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "capstone-web-sg"
  vpc_id = aws_vpc.capstone_vpc.id

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "capstone-app-sg"
  description = "Isolate application tier from direct public exposure"
  vpc_id      = aws_vpc.capstone_vpc.id

  ingress {
    description     = "Allow backend ports strictly from Web tier security group"
    from_port       = 5670
    to_port         = 5670
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_web.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "capstone-public-web-vm"
    Environment = "dev"
    Role        = "Web-Tier"
    Cost-Center = "capstone-101"
    Lifecycle   = "ephemeral"
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name        = "capstone-private-app-vm"
    Environment = "dev"
    Role        = "App-Tier"
    Cost-Center = "capstone-101"
    Lifecycle   = "ephemeral"
  }
}
