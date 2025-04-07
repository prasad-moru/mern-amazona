# MERN Stack Three-Tier Architecture on AWS

This documentation covers the implementation of a three-tier architecture for a MERN (MongoDB, Express.js, React.js, Node.js) stack application on AWS using Terraform as Infrastructure as Code (IaC). The implementation includes deployment automation with Packer and Ansible.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Infrastructure Components](#infrastructure-components)
3. [Terraform Module Structure](#terraform-module-structure)
4. [Infrastructure Deployment](#infrastructure-deployment)
5. [Application Deployment](#application-deployment)
6. [Environment Management](#environment-management)
7. [Security Considerations](#security-considerations)
8. [Monitoring and Logging](#monitoring-and-logging)
9. [Backup and Recovery](#backup-and-recovery)
10. [Cost Optimization](#cost-optimization)
11. [Troubleshooting](#troubleshooting)
12. [Maintenance Procedures](#maintenance-procedures)

## Architecture Overview

The implementation follows a standard three-tier architecture:

1. **Presentation Tier (Frontend)**
   - React.js application
   - Hosted on EC2 instances within an Auto Scaling Group
   - Fronted by an Application Load Balancer
   - Located in private subnets

2. **Application Tier (Backend)**
   - Node.js API application
   - Hosted on EC2 instances
   - Located in private subnets

3. **Data Tier (Database)**
   - AWS DocumentDB (MongoDB-compatible)
   - Located in private subnets

### Network Architecture

- VPC with CIDR range suitable for a mid-sized organization
- 2 public subnets across different Availability Zones
- 2 private subnets across different Availability Zones
- Internet Gateway for internet access from public subnets
- NAT Gateway for outbound internet access from private subnets
- Route tables for proper traffic management

### Access Management

- OpenVPN server deployed on an EC2 instance in a public subnet
- Used for secure administrative access to resources in private subnets

## Infrastructure Components

### VPC Module
- **CIDR Range**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.10.0/24, 10.0.20.0/24
- **Internet Gateway**: Provides internet access
- **NAT Gateway**: Enables outbound internet access for private resources
- **Route Tables**: One for public subnets, one for private subnets

### EC2 Instances Module
- **Frontend Instance**: Hosts React.js application
  - Located in a private subnet
  - Security group restricts access to ALB only
  - No public IP address
- **Backend Instance**: Hosts Node.js application
  - Located in a private subnet
  - Security group restricts access to frontend instances only
  - No public IP address

### Auto Scaling Group Module
- **Launch Template**: Configuration for frontend instances
- **Auto Scaling Group**: Dynamically adjusts capacity
- **Scaling Policies**: Based on CPU utilization
- **CloudWatch Alarms**: Triggers scaling actions

### Application Load Balancer Module
- **ALB**: Distributes traffic to frontend servers
- **Target Group**: Routes requests to backend instances
- **Listeners**: HTTP (port 80) and optional HTTPS (port 443)
- **Security Group**: Allows incoming HTTP/HTTPS traffic

### DocumentDB Module
- **Cluster**: MongoDB-compatible database service
- **Instances**: Configurable number of instances
- **Subnet Group**: Uses private subnets
- **Parameter Group**: Custom configuration settings
- **Security Group**: Restricts access to backend instances only

### OpenVPN Module
- **EC2 Instance**: Hosts OpenVPN server
- **Security Group**: Allows VPN traffic
- **User Configuration**: Sets up two free users
- **Shell Script**: Automated setup via Terraform provisioner

## Terraform Module Structure

```
terraform/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── asg/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── documentdb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── openvpn/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── ...
│   └── prod/
│       ├── ...
```

## Infrastructure Deployment

### Prerequisites

1. AWS Account with appropriate permissions
2. Terraform v1.5.0 or later
3. AWS CLI configured with proper credentials
4. S3 bucket for Terraform state
5. DynamoDB table for state locking

### Deployment Steps

1. **Initialize the Environment**:
   ```bash
   cd terraform/environments/dev
   terraform init
   ```

2. **Create a Workspace** (optional):
   ```bash
   terraform workspace new dev
   ```

3. **Review the Plan**:
   ```bash
   terraform plan
   ```

4. **Apply the Configuration**:
   ```bash
   terraform apply
   ```

5. **Verify Deployment**:
   - Check AWS Console for created resources
   - Confirm connectivity via OpenVPN
   - Verify ALB is accessible

### Automated Deployment with GitHub Actions

A GitHub Actions workflow is configured to automate the deployment process:

1. **Workflow File**: `.github/workflows/terraform-deploy.yml`
2. **Trigger Events**:
   - Push to main branch
   - Pull request to main branch
   - Manual workflow dispatch
3. **Environment Variables**:
   - AWS credentials from GitHub Secrets
   - Database password from GitHub Secrets
4. **Job Steps**:
   - Checkout repository
   - Setup Terraform
   - Determine environment
   - Initialize Terraform
   - Check formatting
   - Validate configuration
   - Generate and review plan
   - Apply configuration (if on main branch)

## Application Deployment

The application deployment uses a combination of Packer and Ansible to create golden AMIs and configure the instances.

### Packer Templates

1. **Frontend Template**: `packer/frontend.json`
   - Builds from Ubuntu 20.04 base AMI
   - Installs Nginx, Node.js, and other dependencies
   - Copies application code
   - Runs Ansible for configuration

2. **Backend Template**: `packer/backend.json`
   - Builds from Ubuntu 20.04 base AMI
   - Installs Node.js and MongoDB clients
   - Copies application code
   - Runs Ansible for configuration

### Ansible Roles

1. **Frontend Role**:
   - Installs and configures Nginx
   - Builds React application
   - Sets up environment files
   - Configures service startup

2. **Backend Role**:
   - Installs and configures Node.js
   - Sets up environment files
   - Configures PM2 for process management
   - Sets up systemd service

### Automated Deployment with GitHub Actions

A GitHub Actions workflow is configured to automate the application deployment:

1. **Workflow File**: `.github/workflows/application-deploy.yml`
2. **Trigger Events**:
   - Push to main branch with changes in application directories
   - Pull request to main branch
   - Manual workflow dispatch
3. **Job Steps**:
   - Checkout repository
   - Setup Node.js
   - Install Packer and Ansible
   - Determine which component to deploy
   - Build AMIs with Packer
   - Update Launch Templates
   - Refresh Auto Scaling Group instances

## Environment Management

### Environment Separation

The infrastructure is designed to support multiple environments (dev, staging, prod) using:

1. **Terraform Workspaces**:
   - Separate workspace for each environment
   - Environment-specific state files

2. **Environment-Specific Variables**:
   - Different `terraform.tfvars` files for each environment
   - Environment-specific configurations

3. **Resource Naming**:
   - Environment name included in resource names
   - Tags for easy identification

### Environment-Specific Configurations

1. **Development**:
   - Smaller instance types
   - Fewer instances
   - Simplified security requirements
   - No HTTPS requirement

2. **Staging**:
   - Similar to production but smaller scale
   - Configured for testing new features
   - May have additional monitoring

3. **Production**:
   - Larger instances
   - More instances for redundancy
   - Strict security settings
   - HTTPS required
   - Full backup and monitoring

## Security Considerations

### Network Security

1. **VPC Isolation**:
   - Private subnets for all application components
   - Public subnets only for load balancers and VPN

2. **Security Groups**:
   - Principle of least privilege
   - Limited access between tiers
   - No direct public access to private resources

3. **Access Control**:
   - OpenVPN for administrative access
   - SSH access restricted to VPN users
   - No direct SSH access from the internet

### Data Security

1. **Data Encryption**:
   - DocumentDB storage encryption
   - HTTPS for data in transit
   - Secure environment variables

2. **Authentication**:
   - IAM roles for EC2 instances
   - Strong database credentials
   - JWT for API authentication

### Compliance

1. **Logging**:
   - VPC Flow Logs
   - CloudTrail for API activity
   - Application logs centralized

2. **Monitoring**:
   - CloudWatch Alarms
   - Resource utilization tracking
   - Security event notifications

## Monitoring and Logging

### CloudWatch Integration

1. **Metrics**:
   - EC2 instance metrics
   - ALB metrics
   - DocumentDB metrics
   - Custom application metrics

2. **Alarms**:
   - CPU utilization alarms for scaling
   - Error rate alarms
   - Latency alarms

3. **Logs**:
   - Application logs
   - Access logs
   - System logs
   - Database logs

### Dashboards

Recommended CloudWatch dashboards for monitoring:

1. **Infrastructure Dashboard**:
   - EC2 instances health
   - ALB statistics
   - Database performance
   - Network traffic

2. **Application Dashboard**:
   - API response times
   - Error rates
   - User activity
   - Business metrics

## Backup and Recovery

### Database Backup

1. **Automated Backups**:
   - DocumentDB automated snapshots
   - Configurable retention period

2. **Manual Snapshots**:
   - Before major changes
   - For long-term retention

### AMI Management

1. **Golden AMI Strategy**:
   - Versioned AMIs created with Packer
   - Previous AMIs retained for rollback

2. **Disaster Recovery**:
   - Cross-region AMI copies
   - Recovery procedures documented

## Cost Optimization

### Resource Optimization

1. **Right-Sizing**:
   - Instance types appropriate for workload
   - Auto Scaling to match demand

2. **Reserved Instances**:
   - For predictable workloads
   - Significant savings for long-term usage

### Monitoring Costs

1. **AWS Cost Explorer**:
   - Regular review of costs
   - Identify cost anomalies

2. **Budgets and Alerts**:
   - Set budget thresholds
   - Alerts for unexpected spending

## Troubleshooting

### Common Issues

1. **Connectivity Problems**:
   - Check security groups
   - Verify route tables
   - Confirm VPN is working

2. **Application Errors**:
   - Check application logs
   - Verify environment variables
   - Test database connectivity

3. **Deployment Failures**:
   - Review GitHub Actions logs
   - Check Terraform state
   - Verify AWS permissions

### Diagnostic Procedures

1. **SSH Access via VPN**:
   - Connect to OpenVPN
   - SSH to instances for direct inspection
   - Check service status

2. **Log Analysis**:
   - Access CloudWatch Logs
   - Review application logs
   - Check system logs

## Maintenance Procedures

### Regular Maintenance

1. **System Updates**:
   - OS patches via new AMIs
   - Dependency updates
   - Security patches

2. **Database Maintenance**:
   - Performance optimization
   - Index management
   - Storage management

### Scaling Procedures

1. **Vertical Scaling**:
   - Change instance types
   - Update Launch Templates
   - Refresh instances

2. **Horizontal Scaling**:
   - Adjust Auto Scaling group parameters
   - Add database instances
   - Update load balancer configuration

### Backup Verification

1. **Regular Testing**:
   - Restore database from backup
   - Deploy from AMI backups
   - Verify application functionality

## Conclusion

This documentation provides a comprehensive guide to the MERN stack three-tier architecture implemented on AWS using Terraform. The modular approach allows for easy maintenance, scaling, and adaptation to changing requirements. The combination of infrastructure as code, golden AMIs, and automated deployment pipelines ensures consistent, reliable, and efficient operations.
