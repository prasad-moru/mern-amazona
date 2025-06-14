# modules/alb/main.tf
resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = var.enable_http2
  idle_timeout              = var.idle_timeout

  # Access logs (optional - can be enabled later)
  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Name        = var.alb_name
    Component   = var.component_type
    Environment = var.environment
    Project     = var.project_name
  }
}