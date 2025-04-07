// modules/ec2/variables.tf
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "vpn_security_group_id" {
  description = "Security group ID for the VPN server"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for naming resources"
  type        = string
  default     = "mern-app"
}

variable "frontend_ami_id" {
  description = "AMI ID for the frontend server"
  type        = string
}

variable "backend_ami_id" {
  description = "AMI ID for the backend server"
  type        = string
}

variable "frontend_instance_type" {
  description = "Instance type for the frontend server"
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "Instance type for the backend server"
  type        = string
  default     = "t3.small"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}