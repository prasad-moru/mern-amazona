# modules/launch-template-ssm/variables.tf
variable "template_name" {
  description = "Name of the launch template"
  type        = string
}

variable "template_description" {
  description = "Description of the launch template"
  type        = string
}

variable "ami_parameter_name" {
  description = "SSM parameter name containing the AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "user_data" {
  description = "User data script (base64 encoded)"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "component_type" {
  description = "Component type for tagging (e.g., frontend, backend)"
  type        = string
}
