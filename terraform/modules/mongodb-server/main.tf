# modules/mongodb-server/main.tf
# Data source to get AMI ID from SSM Parameter Store
data "aws_ssm_parameter" "mongodb_ami_id" {
  name = var.ami_parameter_name
}

# Data source for availability zone
data "aws_subnet" "selected" {
  id = var.subnet_id
}

# EBS Volume for MongoDB Data
resource "aws_ebs_volume" "mongodb_data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.data_volume_size
  type              = var.data_volume_type
  iops              = var.data_volume_type == "gp3" ? var.data_volume_iops : null
  throughput        = var.data_volume_type == "gp3" ? 125 : null
  encrypted         = true

  tags = {
    Name        = "${var.instance_name}-data"
    Component   = "database-storage"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "mongodb-data"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# MongoDB EC2 Instance
resource "aws_instance" "mongodb" {
  ami                         = data.aws_ssm_parameter.mongodb_ami_id.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  availability_zone           = data.aws_subnet.selected.availability_zone
  associate_public_ip_address = false

  monitoring = var.enable_monitoring

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name        = "${var.instance_name}-root"
      Component   = "database-storage"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  # Golden AMI - No user data needed (MongoDB pre-configured)
  user_data = ""

  tags = {
    Name        = var.instance_name
    Component   = "database"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "database"
    Type        = "mongodb"
    AMISource   = "SSM:${var.ami_parameter_name}"
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes       = [ami]
  }
}

# Attach EBS Volume to Instance
resource "aws_volume_attachment" "mongodb_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.mongodb_data.id
  instance_id = aws_instance.mongodb.id

  # Ensure instance is running before attaching
  depends_on = [aws_instance.mongodb]
}

# Elastic IP for MongoDB (Optional - for consistent private IP)
resource "aws_eip" "mongodb" {
  count    = var.environment == "production" ? 1 : 0
  instance = aws_instance.mongodb.id
  domain   = "vpc"

  tags = {
    Name        = "${var.instance_name}-eip"
    Component   = "elasticip"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_instance.mongodb]
}

# CloudWatch Log Group for MongoDB
resource "aws_cloudwatch_log_group" "mongodb" {
  name              = "/aws/ec2/${var.instance_name}"
  retention_in_days = 14

  tags = {
    Name        = "${var.instance_name}-logs"
    Component   = "logging"
    Environment = var.environment
    Project     = var.project_name
  }
}