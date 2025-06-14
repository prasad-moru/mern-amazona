# modules/openvpn-server/outputs.tf
output "instance_id" {
  description = "ID of the OpenVPN EC2 instance"
  value       = aws_instance.openvpn.id
}

output "instance_arn" {
  description = "ARN of the OpenVPN EC2 instance"
  value       = aws_instance.openvpn.arn
}

output "private_ip" {
  description = "Private IP address of the OpenVPN instance"
  value       = aws_instance.openvpn.private_ip
}

output "public_ip" {
  description = "Public IP address of the OpenVPN instance"
  value       = var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : aws_instance.openvpn.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address of the OpenVPN server (if created)"
  value       = var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : null
}

output "private_dns" {
  description = "Private DNS name of the OpenVPN instance"
  value       = aws_instance.openvpn.private_dns
}

output "public_dns" {
  description = "Public DNS name of the OpenVPN instance"
  value       = aws_instance.openvpn.public_dns
}

output "availability_zone" {
  description = "Availability zone of the OpenVPN instance"
  value       = aws_instance.openvpn.availability_zone
}

output "security_group_ids" {
  description = "Security group IDs attached to the instance"
  value       = var.security_group_ids
}

output "admin_console_url" {
  description = "OpenVPN Admin Console URL (if using OpenVPN Access Server)"
  value       = "https://${var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : aws_instance.openvpn.public_ip}:943/admin"
}

output "client_web_url" {
  description = "OpenVPN Client Web Interface URL"
  value       = "https://${var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : aws_instance.openvpn.public_ip}:943/"
}

output "connection_info" {
  description = "Connection information for OpenVPN server"
  value = {
    ssh_command     = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : aws_instance.openvpn.public_ip}"
    admin_console   = "https://${var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : aws_instance.openvpn.public_ip}:943/admin"
    client_download = "https://${var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : aws_instance.openvpn.public_ip}:943/"
    server_ip       = var.create_elastic_ip ? aws_eip.openvpn[0].public_ip : aws_instance.openvpn.public_ip
  }
}