# outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.erp_crm_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.erp_crm_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.erp_crm_igw.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.erp_crm_nat.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.erp_crm_public1.id, aws_subnet.erp_crm_public2.id]
}

output "frontend_subnet_ids" {
  description = "IDs of the private frontend subnets"
  value       = [aws_subnet.erp_crm_private1.id, aws_subnet.erp_crm_private2.id]
}

output "backend_subnet_ids" {
  description = "IDs of the private backend subnets"
  value       = [aws_subnet.erp_crm_private3.id, aws_subnet.erp_crm_private4.id]
}

output "database_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = [aws_subnet.erp_crm_private5.id, aws_subnet.erp_crm_private6.id]
}

# Legacy output for backward compatibility
output "private_subnet_ids" {
  description = "IDs of all private subnets (frontend + backend + database)"
  value       = [
    aws_subnet.erp_crm_private1.id, 
    aws_subnet.erp_crm_private2.id,
    aws_subnet.erp_crm_private3.id,
    aws_subnet.erp_crm_private4.id,
    aws_subnet.erp_crm_private5.id,
    aws_subnet.erp_crm_private6.id
  ]
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.erp_crm_public_rt.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.erp_crm_private_rt.id
}

output "nat_gateway_ip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.erp_crm_nat_eip.public_ip
}