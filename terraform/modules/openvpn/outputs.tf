// modules/openvpn/outputs.tf
output "instance_id" {
  description = "ID of the OpenVPN instance"
  value       = aws_instance.openvpn.id
}

output "public_ip" {
  description = "Public IP of the OpenVPN instance"
  value       = aws_eip.openvpn.public_ip
}

output "security_group_id" {
  description = "ID of the OpenVPN security group"
  value       = aws_security_group.openvpn.id
}