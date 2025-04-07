// environments/dev/main.tf
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "mern-app-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mern-app-terraform-lock"
    encrypt        = true
  }
}

locals {
  environment = "dev"
  name_prefix = "${var.project_name}-${local.environment}"
  
  tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"
  
  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  tags                 = local.tags
}

module "openvpn" {
  source = "../../modules/openvpn"
  
  name_prefix           = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  openvpn_ami_id        = var.openvpn_ami_id
  instance_type         = var.openvpn_instance_type
  key_name              = var.key_name
  allowed_ssh_cidr_blocks = var.allowed_ssh_cidr_blocks
  tags                  = local.tags
}

module "alb" {
  source = "../../modules/alb"
  
  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  enable_deletion_protection = false
  create_https_listener      = var.create_https_listener
  certificate_arn            = var.certificate_arn
  tags                       = local.tags
}

module "ec2" {
  source = "../../modules/ec2"
  
  name_prefix            = local.name_prefix
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  alb_security_group_id  = module.alb.alb_security_group_id
  vpn_security_group_id  = module.openvpn.security_group_id
  frontend_ami_id        = var.frontend_ami_id
  backend_ami_id         = var.backend_ami_id
  frontend_instance_type = var.frontend_instance_type
  backend_instance_type  = var.backend_instance_type
  key_name               = var.key_name
  backend_port           = var.backend_port
  tags                   = local.tags
}

module "asg" {
  source = "../../modules/asg"
  
  name_prefix              = local.name_prefix
  frontend_ami_id          = var.frontend_ami_id
  frontend_instance_type   = var.frontend_instance_type
  key_name                 = var.key_name
  frontend_sg_id           = module.ec2.frontend_sg_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  min_size                 = var.asg_min_size
  max_size                 = var.asg_max_size
  desired_capacity         = var.asg_desired_capacity
  frontend_target_group_arn = module.alb.target_group_arn
  tags                     = local.tags
}

module "documentdb" {
  source = "../../modules/documentdb"
  
  name_prefix               = local.name_prefix
  private_subnet_ids        = module.vpc.private_subnet_ids
  database_security_group_id = module.ec2.database_sg_id
  master_username           = var.db_master_username
  master_password           = var.db_master_password
  instance_class            = var.db_instance_class
  instance_count            = var.db_instance_count
  deletion_protection       = false
  skip_final_snapshot       = true
  tags                      = local.tags
}