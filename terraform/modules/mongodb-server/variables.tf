# modules/mongodb-server/variables.tf
variable "instance_name" {
  description = "Name of the MongoDB instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for MongoDB server"
  type        = string
  default     = "t3.medium"
}

variable "ami_parameter_name" {
  description = "SSM parameter name containing the MongoDB AMI ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where MongoDB instance will be launched"
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
  default     = 30
}

variable "data_volume_size" {
  description = "Size of the MongoDB data volume in GB"
  type        = number
  default     = 100
}

variable "data_volume_type" {
  description = "Type of the data volume"
  type        = string
  default     = "gp3"
}

variable "data_volume_iops" {
  description = "IOPS for the data volume"
  type        = number
  default     = 3000
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the instance"
  type        = string
  default     = null
}
