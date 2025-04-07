// modules/asg/variables.tf
variable "name_prefix" {
  description = "Prefix to use for naming resources"
  type        = string
  default     = "mern-app"
}

variable "frontend_ami_id" {
  description = "AMI ID for the frontend servers"
  type        = string
}

variable "frontend_instance_type" {
  description = "Instance type for the frontend servers"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for instances"
  type        = string
}

variable "frontend_sg_id" {
  description = "ID of the frontend security group"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum size of the auto scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the auto scaling group"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired capacity of the auto scaling group"
  type        = number
  default     = 2
}

variable "frontend_target_group_arn" {
  description = "ARN of the frontend target group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}