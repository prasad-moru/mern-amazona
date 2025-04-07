// modules/alb/outputs.tf
output "alb_id" {
  description = "ID of the ALB"
  value       = aws_lb.frontend.id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.frontend.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.frontend.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.frontend.arn
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}