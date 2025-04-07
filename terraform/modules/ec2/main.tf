// modules/ec2/main.tf
// Frontend Security Group
resource "aws_security_group" "frontend" {
  name        = "${var.name_prefix}-frontend-sg"
  description = "Security group for frontend servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description     = "SSH from VPN"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.vpn_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-frontend-sg"
    }
  )
}

// Backend Security Group
resource "aws_security_group" "backend" {
  name        = "${var.name_prefix}-backend-sg"
  description = "Security group for backend servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "API from Frontend"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  ingress {
    description     = "SSH from VPN"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.vpn_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-backend-sg"
    }
  )
}

// Database Security Group
resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-database-sg"
  description = "Security group for DocumentDB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MongoDB from Backend"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-database-sg"
    }
  )
}

// Frontend EC2 Instance
resource "aws_instance" "frontend" {
  ami                    = var.frontend_ami_id
  instance_type          = var.frontend_instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.frontend.id]
  key_name               = var.key_name
  
  // No public IP as per requirement
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              echo "Frontend server setup script"
              # Additional setup commands would go here
              EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-frontend"
    }
  )
}

// Backend EC2 Instance
resource "aws_instance" "backend" {
  ami                    = var.backend_ami_id
  instance_type          = var.backend_instance_type
  subnet_id              = var.private_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.backend.id]
  key_name               = var.key_name
  
  // No public IP as per requirement
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              echo "Backend server setup script"
              # Additional setup commands would go here
              EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-backend"
    }
  )
}