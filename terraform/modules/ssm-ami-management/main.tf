# modules/ssm-ami-management/main.tf
# SSM Parameter Store for Current AMI ID
resource "aws_ssm_parameter" "current_ami_id" {
  name        = "/${var.project_name}/${var.environment}/${var.component_name}/ami-id"
  description = "Current AMI ID for ${var.component_name} in ${var.environment}"
  type        = "String"
  value       = var.initial_ami_id

  tags = {
    Name        = "${var.project_name}-${var.component_name}-ami-id"
    Component   = "ssm-parameter"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.component_name
    Purpose     = "ami-management"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

# SSM Parameter for AMI Version/Build Number
resource "aws_ssm_parameter" "ami_version" {
  name        = "/${var.project_name}/${var.environment}/${var.component_name}/ami-version"
  description = "Current AMI version/build number for ${var.component_name}"
  type        = "String"
  value       = "1.0.0"

  tags = {
    Name        = "${var.project_name}-${var.component_name}-ami-version"
    Component   = "ssm-parameter"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.component_name
    Purpose     = "version-tracking"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

# SSM Parameter for Previous AMI ID (for rollback)
resource "aws_ssm_parameter" "previous_ami_id" {
  name        = "/${var.project_name}/${var.environment}/${var.component_name}/previous-ami-id"
  description = "Previous AMI ID for rollback purposes"
  type        = "String"
  value       = var.initial_ami_id

  tags = {
    Name        = "${var.project_name}-${var.component_name}-previous-ami-id"
    Component   = "ssm-parameter"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.component_name
    Purpose     = "rollback-support"
  }

  lifecycle {
    ignore_changes = [value]
  }
}
