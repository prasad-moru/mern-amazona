# modules/launch-template-ssm/main.tf
# Data source to get AMI ID from SSM Parameter Store
data "aws_ssm_parameter" "ami_id" {
  name = var.ami_parameter_name
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.template_name}-"
  description   = var.template_description
  image_id      = data.aws_ssm_parameter.ami_id.value
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  user_data = var.user_data != "" ? var.user_data : null

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [1] : []
    content {
      name = var.iam_instance_profile
    }
  }

  monitoring {
    enabled = var.monitoring_enabled
  }

  ebs_optimized = var.ebs_optimized

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.template_name}-instance"
      Component   = var.component_type
      Environment = var.environment
      Project     = var.project_name
      AMISource   = "SSM:${var.ami_parameter_name}"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "${var.template_name}-volume"
      Component   = var.component_type
      Environment = var.environment
      Project     = var.project_name
    }
  }

  tags = {
    Name        = var.template_name
    Component   = "launchtemplate"
    Environment = var.environment
    Project     = var.project_name
    AMISource   = "SSM:${var.ami_parameter_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
