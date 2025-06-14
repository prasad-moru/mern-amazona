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

output "private_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = module.vpc.database_subnet_ids
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

# Formatted outputs for easy reference
output "network_summary" {
  description = "Summary of network infrastructure"
  value = {
    vpc_id              = module.vpc.vpc_id
    vpc_cidr           = module.vpc.vpc_cidr_block
    public_subnets     = module.vpc.public_subnet_ids
    private_subnets    = module.vpc.private_subnet_ids
    database_subnets   = module.vpc.database_subnet_ids
    nat_gateway_ip     = module.vpc.nat_gateway_ip
  }
}