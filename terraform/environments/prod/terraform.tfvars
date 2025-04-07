// environments/dev/terraform.tfvars
aws_region = "us-east-1"
project_name = "mern-app"

# VPC settings
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
azs = ["us-east-1a", "us-east-1b"]

# EC2 settings
# Note: Replace with actual AMI IDs
frontend_ami_id = "ami-placeholder-frontend"
backend_ami_id = "ami-placeholder-backend"
openvpn_ami_id = "ami-placeholder-openvpn"
frontend_instance_type = "t3.micro"
backend_instance_type = "t3.small"
openvpn_instance_type = "t3.micro"
key_name = "mern-app-key"
backend_port = 3000
allowed_ssh_cidr_blocks = ["YOUR_IP_ADDRESS/32"]

# ASG settings
asg_min_size = 1
asg_max_size = 2
asg_desired_capacity = 2

# ALB settings
create_https_listener = false
certificate_arn = ""

# DocumentDB settings
db_master_username = "admin"
db_master_password = "REPLACE_WITH_SECURE_PASSWORD"  # Replace with a secure password
db_instance_class = "db.t3.medium"
db_instance_count = 1