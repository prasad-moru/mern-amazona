variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "launch_template_id" {
  description = "ID of the launch template"
  type        = string
}

variable "launch_template_version" {
  description = "Version of the launch template to use"
  type        = string
  default     = "$Latest"
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be launched"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "Type of health check (EC2 or ELB)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Grace period for health checks in seconds"
  type        = number
  default     = 300
}

variable "target_group_arns" {
  description = "List of target group ARNs for load balancer"
  type        = list(string)
  default     = []
}

variable "termination_policies" {
  description = "List of termination policies"
  type        = list(string)
  default     = ["Default"]
}

variable "enabled_metrics" {
  description = "List of metrics to enable"
  type        = list(string)
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
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
