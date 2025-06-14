variable "aws_region" {
  description = "AWS region for development environment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ERP-CRM"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for development"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

# EC2 Configuration Variables
variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  default     = "erp-crm-dev-key"
}

# Frontend Instance Configuration
variable "frontend_instance_type" {
  description = "Instance type for frontend servers"
  type        = string
  default     = "t3.micro"
}

variable "frontend_min_size" {
  description = "Minimum number of frontend instances"
  type        = number
  default     = 1
}

variable "frontend_max_size" {
  description = "Maximum number of frontend instances"
  type        = number
  default     = 3
}

variable "frontend_desired_capacity" {
  description = "Desired number of frontend instances"
  type        = number
  default     = 2
}

# Backend Instance Configuration
variable "backend_instance_type" {
  description = "Instance type for backend servers"
  type        = string
  default     = "t3.small"
}

variable "backend_min_size" {
  description = "Minimum number of backend instances"
  type        = number
  default     = 1
}

variable "backend_max_size" {
  description = "Maximum number of backend instances"
  type        = number
  default     = 3
}

variable "backend_desired_capacity" {
  description = "Desired number of backend instances"
  type        = number
  default     = 2
}

# environments/development/variables.tf (ADD MongoDB variables)
# Add these MongoDB variables to your existing variables.tf

# MongoDB Configuration Variables
variable "mongodb_instance_type" {
  description = "Instance type for MongoDB server"
  type        = string
  default     = "t3.medium"
}

variable "mongodb_data_volume_size" {
  description = "Size of MongoDB data volume in GB"
  type        = number
  default     = 100
}

# environments/development/variables.tf (ADD OpenVPN variables)
# Add these OpenVPN variables to your existing variables.tf

# OpenVPN Configuration Variables
variable "openvpn_instance_type" {
  description = "Instance type for OpenVPN server"
  type        = string
  default     = "t3.small"
}

variable "openvpn_ami_id" {
  description = "AMI ID for OpenVPN server (your pre-configured OpenVPN AMI)"
  type        = string
}

variable "vpn_client_network" {
  description = "VPN client IP network (will be configured in OpenVPN admin console)"
  type        = string
  default     = "192.168.100.0/24"
}

variable "admin_ssh_cidr" {
  description = "CIDR block for SSH access to OpenVPN server (restrict to your IP)"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your specific IP range
}
