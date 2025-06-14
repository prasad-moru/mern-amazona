# modules/ssm-ami-management/outputs.tf
output "ami_parameter_name" {
  description = "SSM parameter name for current AMI ID"
  value       = aws_ssm_parameter.current_ami_id.name
}

output "ami_version_parameter_name" {
  description = "SSM parameter name for AMI version"
  value       = aws_ssm_parameter.ami_version.name
}

output "previous_ami_parameter_name" {
  description = "SSM parameter name for previous AMI ID"
  value       = aws_ssm_parameter.previous_ami_id.name
}

output "current_ami_id" {
  description = "Current AMI ID value"
  value       = aws_ssm_parameter.current_ami_id.value
}
