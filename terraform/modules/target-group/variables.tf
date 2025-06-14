# modules/target-group/variables.tf
variable "name" {
  description = "Name of the target group"
  type        = string
}

variable "port" {
  description = "Port on which targets receive traffic"
  type        = number
}

variable "protocol" {
  description = "Protocol to use for routing traffic"
  type        = string
  default     = "HTTP"
}

variable "protocol_version" {
  description = "Protocol version"
  type        = string
  default     = "HTTP1"
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created"
  type        = string
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda)"
  type        = string
  default     = "instance"
}

variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks before considering target healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health checks before considering target unhealthy"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "Health check success codes"
  type        = string
  default     = "200"
}

variable "health_check_port" {
  description = "Port for health checks"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol for health checks"
  type        = string
  default     = "HTTP"
}

variable "deregistration_delay" {
  description = "Time to wait before deregistering a target"
  type        = number
  default     = 300
}

variable "slow_start" {
  description = "Slow start duration in seconds"
  type        = number
  default     = 0
}

variable "stickiness_enabled" {
  description = "Enable session stickiness"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Type of stickiness"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "Cookie duration for stickiness (seconds)"
  type        = number
  default     = 86400
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