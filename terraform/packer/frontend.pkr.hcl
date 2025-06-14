packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "project_name" {
  type    = string
  default = "ERP-CRM"
}

variable "environment" {
  type    = string
  default = "development"
}

variable "component" {
  type    = string
  default = "frontend"
}

variable "version" {
  type    = string
  default = "1.0.0"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "frontend" {
  ami_name      = "${var.project_name}-${var.component}-${var.version}-${local.timestamp}"
  instance_type = "t3.micro"
  region        = "ap-south-1"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags = {
    Name        = "${var.project_name}-${var.component}-${var.version}"
    Component   = var.component
    Environment = var.environment
    Project     = var.project_name
    Version     = var.version
    BuildDate   = timestamp()
  }
}

build {
  name = "frontend-ami"
  sources = [
    "source.amazon-ebs.frontend"
  ]

  # Install Node.js and dependencies
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nodejs npm git",
      "sudo npm install -g pm2 serve",
    ]
  }

  # Copy application files
  provisioner "file" {
    source      = "../frontend/"
    destination = "/tmp/frontend"
  }

  # Setup application
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/frontend",
      "sudo cp -r /tmp/frontend/* /opt/frontend/",
      "cd /opt/frontend && sudo npm install",
      "cd /opt/frontend && sudo npm run build",
      "sudo chown -R ec2-user:ec2-user /opt/frontend"
    ]
  }

  # Create systemd service
  provisioner "file" {
    content = <<EOF
[Unit]
Description=Frontend Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/frontend
ExecStart=/usr/bin/serve -s build -l 3000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    destination = "/tmp/frontend.service"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/frontend.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable frontend",
    ]
  }

  # Update SSM Parameter after successful build
  post-processor "shell-local" {
    inline = [
      "aws ssm put-parameter --name '/${var.project_name}/${var.environment}/${var.component}/ami-id' --value '{{ build `ID` }}' --overwrite",
      "aws ssm put-parameter --name '/${var.project_name}/${var.environment}/${var.component}/ami-version' --value '${var.version}' --overwrite",
      "echo 'Updated SSM parameters with new AMI ID: {{ build `ID` }}'"
    ]
  }
}