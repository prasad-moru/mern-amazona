# modules/openvpn-server/variables.tf
variable "instance_name" {
  description = "Name of the OpenVPN server instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for OpenVPN server"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID for OpenVPN server (your pre-configured OpenVPN AMI)"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where OpenVPN server will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "create_elastic_ip" {
  description = "Create Elastic IP for consistent public IP"
  type        = bool
  default     = true
}
