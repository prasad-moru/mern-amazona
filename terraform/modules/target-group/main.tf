# modules/target-group/main.tf
resource "aws_lb_target_group" "this" {
  name                 = var.name
  port                 = var.port
  protocol             = var.protocol
  protocol_version     = var.protocol_version
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay
  slow_start           = var.slow_start

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    port                = var.health_check_port
    protocol            = var.health_check_protocol
  }

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      enabled         = var.stickiness_enabled
    }
  }

  tags = {
    Name        = var.name
    Component   = "targetgroup"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.component_type
  }

  lifecycle {
    create_before_destroy = true
  }
}