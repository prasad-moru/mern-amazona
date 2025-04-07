// modules/asg/main.tf
// Launch Template for Frontend Servers
resource "aws_launch_template" "frontend" {
  name          = "${var.name_prefix}-frontend-lt"
  image_id      = var.frontend_ami_id
  instance_type = var.frontend_instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.frontend_sg_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Frontend server setup script"
              # Additional setup commands would go here
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-frontend"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

// Auto Scaling Group for Frontend Servers
resource "aws_autoscaling_group" "frontend" {
  name                = "${var.name_prefix}-frontend-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  target_group_arns = [var.frontend_target_group_arn]
  health_check_type = "ELB"

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-frontend"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

// Auto Scaling Policies
resource "aws_autoscaling_policy" "frontend_scale_up" {
  name                   = "${var.name_prefix}-frontend-scale-up"
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "frontend_scale_down" {
  name                   = "${var.name_prefix}-frontend-scale-down"
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

// CloudWatch Alarms for Auto Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.name_prefix}-frontend-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Scale up if CPU utilization is above 80% for 2 consecutive periods of 120 seconds"
  alarm_actions       = [aws_autoscaling_policy.frontend_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.frontend.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.name_prefix}-frontend-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "Scale down if CPU utilization is below 30% for 2 consecutive periods of 120 seconds"
  alarm_actions       = [aws_autoscaling_policy.frontend_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.frontend.name
  }
}