// modules/openvpn/variables.tf
variable "name_prefix" {
  description = "Prefix to use for naming resources"
  type        = string
  default     = "mern-app"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "openvpn_ami_id" {
  description = "AMI ID for the OpenVPN server"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the OpenVPN server"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the key pair to use for the instance"
  type        = string
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to the OpenVPN server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_admin_cidr_blocks" {
  description = "CIDR blocks allowed to access the admin interface"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}