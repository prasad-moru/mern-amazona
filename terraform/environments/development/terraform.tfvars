# environments/development/terraform.tfvars.example
# Copy this file to terraform.tfvars and customize as needed

# AWS Configuration
aws_region = "ap-south-1"

# Project Configuration
environment  = "development"
project_name = "ERP-CRM"

# Network Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["ap-south-1a", "ap-south-1b"]

# Additional environment-specific configurations can be added here
# For example:
# instance_types = {
#   web = "t3.micro"
#   app = "t3.small"
#   db  = "t3.medium"
# }


# EC2 Configuration
key_pair_name = "erp-crm-dev-key"  # Make sure this key pair exists in your AWS account

# Frontend Instance Configuration
frontend_instance_type     = "t3.micro"
frontend_min_size         = 1
frontend_max_size         = 3
frontend_desired_capacity = 2

# Backend Instance Configuration
backend_instance_type     = "t3.small"
backend_min_size         = 1
backend_max_size         = 3
backend_desired_capacity = 2

# environments/development/terraform.tfvars (ADD MongoDB configuration)
# Add these MongoDB configurations to your existing terraform.tfvars

# MongoDB Configuration
mongodb_instance_type     = "t3.medium"
mongodb_data_volume_size = 100

# OpenVPN Configuration
openvpn_instance_type = "t3.small"
openvpn_ami_id       = "ami-xxxxxxxxxxxxxxxxx"  # Your pre-configured OpenVPN AMI
vpn_client_network   = "192.168.100.0/24"
admin_ssh_cidr       = "0.0.0.0/0"  # Restrict this to your IP range in production
