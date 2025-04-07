// modules/asg/outputs.tf
output "frontend_asg_name" {
  description = "Name of the frontend auto scaling group"
  value       = aws_autoscaling_group.frontend.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.frontend.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.frontend.latest_version
}