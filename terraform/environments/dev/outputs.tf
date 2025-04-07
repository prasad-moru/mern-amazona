// environments/dev/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "openvpn_public_ip" {
  description = "Public IP of the OpenVPN server"
  value       = module.openvpn.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.alb.alb_dns_name
}

output "frontend_asg_name" {
  description = "Name of the frontend auto scaling group"
  value       = module.asg.frontend_asg_name
}

output "documentdb_endpoint" {
  description = "Endpoint of the DocumentDB cluster"
  value       = module.documentdb.cluster_endpoint
}

output "documentdb_port" {
  description = "Port of the DocumentDB cluster"
  value       = module.documentdb.port
}