terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

# VPC
resource "aws_vpc" "minecraft" {
  cidr_block = "10.12.23.0/24"
  enable_dns_support   = true
  tags = {
    Name = "minecraft"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.minecraft.id
  cidr_block        = "10.12.23.0/24"
  map_public_ip_on_launch = true

  availability_zone = "us-west-2a"

  tags = {
    Name = "minecraft-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.minecraft.id

  tags = {
    Name = "minecraft-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.minecraft.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "minecraft-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "minecraft-sg" {
  name        = "minecraft-sg"
  description = "Allows minecraft traffic"
  vpc_id      = aws_vpc.minecraft.id

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
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

# Instance
resource "aws_instance" "app_server" {
  ami           = "ami-0a605bc2ef5707a18"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.minecraft-sg.id]
  key_name                    = "windows"

  tags = {
    Name = "Minecraft"
  }

  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update",
        "sudo apt install docker.io docker-compose -y",
        "sudo systemctl enable docker",
        "sudo systemctl start docker",
        "sudo curl -L https://github.com/LucasTStephens/cs312_part2/blob/main/docker-compose.yml -o docker-compose.yml",
        "sudo docker-compose up -d",
    ]

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("windows.pem")
        host        = self.public_ip
    }
  }
}


