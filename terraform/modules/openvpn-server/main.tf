# modules/openvpn-server/main.tf
# Data source for availability zone
data "aws_subnet" "selected" {
  id = var.subnet_id
}

# OpenVPN EC2 Instance
resource "aws_instance" "openvpn" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  availability_zone           = data.aws_subnet.selected.availability_zone
  associate_public_ip_address = true

  monitoring = var.enable_monitoring

  # Disable source/destination check for VPN routing
  source_dest_check = false

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name        = "${var.instance_name}-root"
      Component   = "vpn-storage"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  # No user data - AMI is pre-configured
  user_data = ""

  tags = {
    Name        = var.instance_name
    Component   = "vpn-server"
    Environment = var.environment
    Project     = var.project_name
    Type        = "openvpn"
    Purpose     = "secure-access"
    ConfigMethod = "pre-configured-ami"
  }

  lifecycle {
    create_before_destroy = false
  }
}

# Elastic IP for OpenVPN Server (optional)
resource "aws_eip" "openvpn" {
  count    = var.create_elastic_ip ? 1 : 0
  instance = aws_instance.openvpn.id
  domain   = "vpc"

  tags = {
    Name        = "${var.instance_name}-eip"
    Component   = "elasticip"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "openvpn-server"
  }

  depends_on = [aws_instance.openvpn]
}

# CloudWatch Log Group for OpenVPN
resource "aws_cloudwatch_log_group" "openvpn" {
  name              = "/aws/ec2/${var.instance_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.instance_name}-logs"
    Component   = "logging"
    Environment = var.environment
    Project     = var.project_name
  }
}

# CloudWatch Alarms for OpenVPN Server
resource "aws_cloudwatch_metric_alarm" "openvpn_cpu" {
  alarm_name          = "${var.instance_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors CPU utilization for OpenVPN server"

  dimensions = {
    InstanceId = aws_instance.openvpn.id
  }

  tags = {
    Name        = "${var.instance_name}-cpu-alarm"
    Component   = "monitoring"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "openvpn_status" {
  alarm_name          = "${var.instance_name}-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors instance status check for OpenVPN server"

  dimensions = {
    InstanceId = aws_instance.openvpn.id
  }

  tags = {
    Name        = "${var.instance_name}-status-alarm"
    Component   = "monitoring"
    Environment = var.environment
    Project     = var.project_name
  }
}