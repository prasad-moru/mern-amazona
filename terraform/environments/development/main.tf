
# environments/development/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}


terraform {
  backend "s3" {
    bucket         = "mern-app-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mern-app-terraform-lock"
    encrypt        = true
  }
}

locals {
  environment = "dev"
  name_prefix = "${var.project_name}-${local.environment}"
  
  tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"
  environment = "development"
  project_name = "ERP-CRM"
  region = "ap-south-1"
}


# environments/development/ssm-integration.tf
# Data source for latest Amazon Linux 2 AMI (for initial setup)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ===============================================
# SSM AMI MANAGEMENT
# ===============================================

# Frontend AMI Management
module "frontend_ami_management" {
  source = "../../modules/ssm-ami-management"

  environment    = var.environment
  project_name   = var.project_name
  component_name = "frontend"
  initial_ami_id = data.aws_ami.amazon_linux.id
}

# Backend AMI Management
module "backend_ami_management" {
  source = "../../modules/ssm-ami-management"

  environment    = var.environment
  project_name   = var.project_name
  component_name = "backend"
  initial_ami_id = data.aws_ami.amazon_linux.id
}

# ===============================================
# LAUNCH TEMPLATES WITH SSM INTEGRATION
# ===============================================

# Frontend Launch Template with SSM
module "frontend_launch_template_ssm" {
  source = "../../modules/launch-template-ssm"

  template_name        = "erp-crm-frontend-lt"
  template_description = "Launch template for frontend EC2 instances (SSM managed)"
  ami_parameter_name   = module.frontend_ami_management.ami_parameter_name
  instance_type        = var.frontend_instance_type
  key_name            = var.key_pair_name
  security_group_ids  = [module.sg_frontend_ec2.security_group_id]
  
  user_data = base64encode(templatefile("${path.module}/user-data/frontend-userdata.sh", {
    environment = var.environment
  }))

  root_volume_size = 20
  root_volume_type = "gp3"
  ebs_optimized    = false
  monitoring_enabled = true

  environment    = var.environment
  project_name   = var.project_name
  component_type = "frontend"
}

# Backend Launch Template with SSM
module "backend_launch_template_ssm" {
  source = "../../modules/launch-template-ssm"

  template_name        = "erp-crm-backend-lt"
  template_description = "Launch template for backend EC2 instances (SSM managed)"
  ami_parameter_name   = module.backend_ami_management.ami_parameter_name
  instance_type        = var.backend_instance_type
  key_name            = var.key_pair_name
  security_group_ids  = [module.sg_backend_ec2.security_group_id]
  
  user_data = base64encode(templatefile("${path.module}/user-data/backend-userdata.sh", {
    environment = var.environment
  }))

  root_volume_size = 30
  root_volume_type = "gp3"
  ebs_optimized    = false
  monitoring_enabled = true

  environment    = var.environment
  project_name   = var.project_name
  component_type = "backend"
}

# ===============================================
# AUTO SCALING GROUPS (UPDATED TO USE SSM TEMPLATES)
# ===============================================

# Frontend Auto Scaling Group
module "frontend_asg_ssm" {
  source = "../../modules/autoscaling-group"

  asg_name               = "erp-crm-frontend-asg"
  launch_template_id     = module.frontend_launch_template_ssm.launch_template_id
  launch_template_version = "$Latest"
  
  subnet_ids = module.vpc.frontend_subnet_ids
  
  min_size         = var.frontend_min_size
  max_size         = var.frontend_max_size
  desired_capacity = var.frontend_desired_capacity
  
  health_check_type         = "EC2"
  health_check_grace_period = 300

  environment    = var.environment
  project_name   = var.project_name
  component_type = "frontend"
}

# Backend Auto Scaling Group
module "backend_asg_ssm" {
  source = "../../modules/autoscaling-group"

  asg_name               = "erp-crm-backend-asg"
  launch_template_id     = module.backend_launch_template_ssm.launch_template_id
  launch_template_version = "$Latest"
  
  subnet_ids = module.vpc.backend_subnet_ids
  
  min_size         = var.backend_min_size
  max_size         = var.backend_max_size
  desired_capacity = var.backend_desired_capacity
  
  health_check_type         = "EC2"
  health_check_grace_period = 300

  environment    = var.environment
  project_name   = var.project_name
  component_type = "backend"
}


# environments/development/alb-infrastructure.tf
# ===============================================
# ALB SECURITY GROUPS (UPDATED)
# ===============================================

# Public ALB Security Group (Frontend)
module "sg_public_alb" {
  source = "../../modules/security-groups"

  vpc_id         = module.vpc.vpc_id
  sg_name        = "sg-public-alb"
  sg_description = "Security group for public ALB (frontend)"
  component_type = "alb"
  environment    = var.environment
  project_name   = var.project_name

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from anywhere"
    }
  ]
}

# Private ALB Security Group (Backend)
module "sg_private_alb" {
  source = "../../modules/security-groups"

  vpc_id         = module.vpc.vpc_id
  sg_name        = "sg-private-alb"
  sg_description = "Security group for private ALB (backend)"
  component_type = "alb"
  environment    = var.environment
  project_name   = var.project_name

  ingress_rules = [
    {
      from_port          = 8080
      to_port            = 8080
      protocol           = "tcp"
      security_group_ids = [module.sg_frontend_ec2.security_group_id]
      description        = "Backend API port from frontend EC2"
    }
  ]
}

# ===============================================
# APPLICATION LOAD BALANCERS
# ===============================================

# Public ALB (Frontend)
module "public_alb" {
  source = "../../modules/alb"

  alb_name           = "erp-crm-public-alb"
  internal           = false
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.sg_public_alb.security_group_id]

  enable_deletion_protection = var.environment == "production" ? true : false
  enable_http2              = true
  idle_timeout              = 60

  environment    = var.environment
  project_name   = var.project_name
  component_type = "frontend-alb"
}

# Private ALB (Backend)
module "private_alb" {
  source = "../../modules/alb"

  alb_name           = "erp-crm-private-alb"
  internal           = true
  subnet_ids         = module.vpc.backend_subnet_ids
  security_group_ids = [module.sg_private_alb.security_group_id]

  enable_deletion_protection = false
  enable_http2              = true
  idle_timeout              = 60

  environment    = var.environment
  project_name   = var.project_name
  component_type = "backend-alb"
}

# ===============================================
# TARGET GROUPS
# ===============================================

# Frontend Target Group
module "frontend_target_group" {
  source = "../../modules/target-group"

  name             = "erp-crm-frontend-tg"
  port             = 3000
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  vpc_id           = module.vpc.vpc_id
  target_type      = "instance"

  # Health check configuration for React app
  health_check_enabled             = true
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 3
  health_check_timeout             = 5
  health_check_interval            = 30
  health_check_path                = "/"
  health_check_matcher             = "200"
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"

  # Connection settings
  deregistration_delay = 300
  slow_start          = 30

  # Stickiness (optional for frontend)
  stickiness_enabled = false

  environment    = var.environment
  project_name   = var.project_name
  component_type = "frontend"
}

# Backend Target Group
module "backend_target_group" {
  source = "../../modules/target-group"

  name             = "erp-crm-backend-tg"
  port             = 8080
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  vpc_id           = module.vpc.vpc_id
  target_type      = "instance"

  # Health check configuration for Express API
  health_check_enabled             = true
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 3
  health_check_timeout             = 5
  health_check_interval            = 30
  health_check_path                = "/health"
  health_check_matcher             = "200"
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"

  # Connection settings
  deregistration_delay = 300
  slow_start          = 30

  # Stickiness for API sessions (if needed)
  stickiness_enabled = false

  environment    = var.environment
  project_name   = var.project_name
  component_type = "backend"
}

# ===============================================
# ALB LISTENERS
# ===============================================

# Public ALB Listener (HTTP)
resource "aws_lb_listener" "public_alb_http" {
  load_balancer_arn = module.public_alb.alb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.frontend_target_group.target_group_arn
  }

  tags = {
    Name        = "erp-crm-public-alb-listener-http"
    Component   = "alb-listener"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Private ALB Listener (HTTP)
resource "aws_lb_listener" "private_alb_http" {
  load_balancer_arn = module.private_alb.alb_arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.backend_target_group.target_group_arn
  }

  tags = {
    Name        = "erp-crm-private-alb-listener-http"
    Component   = "alb-listener"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ===============================================
# UPDATED AUTO SCALING GROUPS WITH TARGET GROUP INTEGRATION
# ===============================================

# Updated Frontend ASG with Target Group
module "frontend_asg_with_alb" {
  source = "../../modules/autoscaling-group"

  asg_name               = "erp-crm-frontend-asg"
  launch_template_id     = module.frontend_launch_template.launch_template_id
  launch_template_version = "$Latest"
  
  subnet_ids = module.vpc.frontend_subnet_ids
  
  min_size         = var.frontend_min_size
  max_size         = var.frontend_max_size
  desired_capacity = var.frontend_desired_capacity
  
  health_check_type         = "ELB"  # Changed to ELB for ALB integration
  health_check_grace_period = 300
  
  # THIS IS THE MAGIC - ALB Integration
  target_group_arns = [module.frontend_target_group.target_group_arn]

  environment    = var.environment
  project_name   = var.project_name
  component_type = "frontend"
}

# Updated Backend ASG with Target Group
module "backend_asg_with_alb" {
  source = "../../modules/autoscaling-group"

  asg_name               = "erp-crm-backend-asg"
  launch_template_id     = module.backend_launch_template.launch_template_id
  launch_template_version = "$Latest"
  
  subnet_ids = module.vpc.backend_subnet_ids
  
  min_size         = var.backend_min_size
  max_size         = var.backend_max_size
  desired_capacity = var.backend_desired_capacity
  
  health_check_type         = "ELB"  # Changed to ELB for ALB integration
  health_check_grace_period = 300
  
  # THIS IS THE MAGIC - ALB Integration
  target_group_arns = [module.backend_target_group.target_group_arn]

  environment    = var.environment
  project_name   = var.project_name
  component_type = "backend"
}
