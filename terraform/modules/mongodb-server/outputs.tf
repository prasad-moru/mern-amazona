output "instance_id" {
  description = "ID of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.id
}

output "instance_arn" {
  description = "ARN of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.arn
}

output "private_ip" {
  description = "Private IP address of the MongoDB instance"
  value       = aws_instance.mongodb.private_ip
}

output "private_dns" {
  description = "Private DNS name of the MongoDB instance"
  value       = aws_instance.mongodb.private_dns
}

output "public_ip" {
  description = "Public IP address of the MongoDB instance (if applicable)"
  value       = var.environment == "production" ? aws_eip.mongodb[0].public_ip : aws_instance.mongodb.public_ip
}

output "availability_zone" {
  description = "Availability zone of the MongoDB instance"
  value       = aws_instance.mongodb.availability_zone
}

output "data_volume_id" {
  description = "ID of the MongoDB data EBS volume"
  value       = aws_ebs_volume.mongodb_data.id
}

output "data_volume_size" {
  description = "Size of the MongoDB data volume"
  value       = aws_ebs_volume.mongodb_data.size
}

output "current_ami_id" {
  description = "Current AMI ID being used"
  value       = data.aws_ssm_parameter.mongodb_ami_id.value
}

output "connection_string" {
  description = "MongoDB connection string template"
  value       = "mongodb://username:password@${aws_instance.mongodb.private_ip}:27017/database_name"
  sensitive   = true
}

# Get current region for URLs
data "aws_region" "current" {}