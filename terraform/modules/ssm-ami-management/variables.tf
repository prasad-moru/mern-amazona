# modules/ssm-ami-management/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "component_name" {
  description = "Component name (frontend/backend)"
  type        = string
}

variable "initial_ami_id" {
  description = "Initial AMI ID to store in parameter"
  type        = string
}