output "ip" {
    description = "minecraft server public IP"
    value = aws_instance.app_server.public_ip
  }