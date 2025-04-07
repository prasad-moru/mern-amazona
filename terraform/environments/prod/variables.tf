// environments/dev/variables.tf
variable "aws_region" {
  description = "AWS region to use"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "mern-app"
}

// VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

// EC2 Variables
variable "frontend_ami_id" {
  description = "AMI ID for the frontend servers"
  type        = string
}

variable "backend_ami_id" {
  description = "AMI ID for the backend servers"
  type        = string
}

variable "openvpn_ami_id" {
  description = "AMI ID for the OpenVPN server"
  type        = string
}

variable "frontend_instance_type" {
  description = "Instance type for the frontend servers"
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "Instance type for the backend servers"
  type        = string
  default     = "t3.small"
}

variable "openvpn_instance_type" {
  description = "Instance type for the OpenVPN server"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for instances"
  type        = string
}

variable "backend_port" {
  description = "Port that the backend service listens on"
  type        = number
  default     = 3000
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to the OpenVPN server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

// Auto Scaling Group Variables
variable "asg_min_size" {
  description = "Minimum size of the auto scaling group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the auto scaling group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the auto scaling group"
  type        = number
  default     = 2
}

// ALB Variables
variable "create_https_listener" {
  description = "Whether to create an HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate to use for HTTPS"
  type        = string
  default     = ""
}

// DocumentDB Variables
variable "db_master_username" {
  description = "Master username for the DocumentDB cluster"
  type        = string
  default     = "admin"
}

variable "db_master_password" {
  description = "Master password for the DocumentDB cluster"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for DocumentDB instances"
  type        = string
  default     = "db.t3.medium"
}

variable "db_instance_count" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 1
}