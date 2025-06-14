resource "aws_autoscaling_group" "this" {
  name                = var.asg_name
  vpc_zone_identifier = var.subnet_ids
  
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  target_group_arns = var.target_group_arns

  termination_policies = var.termination_policies
  enabled_metrics      = var.enabled_metrics

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = false
  }

  tag {
    key                 = "Component"
    value               = "autoscalinggroup"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = var.component_type
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}