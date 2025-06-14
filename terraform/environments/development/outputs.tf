# environments/development/outputs.tf (ENHANCED)
# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_ip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "frontend_subnet_ids" {
  description = "IDs of the private frontend subnets"
  value       = module.vpc.frontend_subnet_ids
}

output "backend_subnet_ids" {
  description = "IDs of the private backend subnets"
  value       = module.vpc.backend_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = module.vpc.database_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of all private subnets"
  value       = module.vpc.private_subnet_ids
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = module.vpc.private_route_table_id
}

# SSM Parameter Outputs
output "ssm_parameters" {
  description = "SSM parameter names for AMI management"
  value = {
    frontend_ami_id = module.frontend_ami_management.ami_parameter_name
    frontend_version = module.frontend_ami_management.ami_version_parameter_name
    frontend_previous_ami = module.frontend_ami_management.previous_ami_parameter_name
    backend_ami_id = module.backend_ami_management.ami_parameter_name
    backend_version = module.backend_ami_management.ami_version_parameter_name
    backend_previous_ami = module.backend_ami_management.previous_ami_parameter_name
  }
}

# ALB Outputs
output "load_balancers" {
  description = "Load balancer details"
  value = {
    public_alb = {
      id       = module.public_alb.alb_id
      dns_name = module.public_alb.alb_dns_name
      arn      = module.public_alb.alb_arn
      zone_id  = module.public_alb.alb_zone_id
    }
    private_alb = {
      id       = module.private_alb.alb_id
      dns_name = module.private_alb.alb_dns_name
      arn      = module.private_alb.alb_arn
      zone_id  = module.private_alb.alb_zone_id
    }
  }
}

# Target Group Outputs
output "target_groups" {
  description = "Target group details"
  value = {
    frontend = {
      id   = module.frontend_target_group.target_group_id
      arn  = module.frontend_target_group.target_group_arn
      name = module.frontend_target_group.target_group_name
      port = module.frontend_target_group.target_group_port
    }
    backend = {
      id   = module.backend_target_group.target_group_id
      arn  = module.backend_target_group.target_group_arn
      name = module.backend_target_group.target_group_name
      port = module.backend_target_group.target_group_port
    }
  }
}

# Security Group Outputs
output "security_groups" {
  description = "Security group IDs"
  value = {
    public_alb   = module.sg_public_alb.security_group_id
    private_alb  = module.sg_private_alb.security_group_id
    frontend_ec2 = module.sg_frontend_ec2.security_group_id
    backend_ec2  = module.sg_backend_ec2.security_group_id
  }
}

# Application URLs
output "application_urls" {
  description = "Application access URLs"
  value = {
    frontend_url = "http://${module.public_alb.alb_dns_name}"
    backend_url  = "http://${module.private_alb.alb_dns_name}:8080"
  }
}

# Complete Infrastructure Summary
output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    # Network
    vpc_id              = module.vpc.vpc_id
    frontend_subnets    = module.vpc.frontend_subnet_ids
    backend_subnets     = module.vpc.backend_subnet_ids
    database_subnets    = module.vpc.database_subnet_ids
    
    # Load Balancers
    frontend_alb_dns = module.public_alb.alb_dns_name
    backend_alb_dns  = module.private_alb.alb_dns_name
    
    # Auto Scaling Groups
    frontend_asg = module.frontend_asg.autoscaling_group_name
    backend_asg  = module.backend_asg.autoscaling_group_name
    
    # SSM Parameters
    ssm_parameters = {
      frontend_ami = module.frontend_ami_management.ami_parameter_name
      backend_ami  = module.backend_ami_management.ami_parameter_name
    }
  }
}