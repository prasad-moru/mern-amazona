# VPC
resource "aws_vpc" "erp_crm_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "erp-crm"
    Component   = "vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "erp_crm_igw" {
  vpc_id = aws_vpc.erp_crm_vpc.id

  tags = {
    Name        = "erp-crm-igw"
    Component   = "internetgateway"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public Subnets
resource "aws_subnet" "erp_crm_public1" {
  vpc_id                  = aws_vpc.erp_crm_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "erp-crm-public1"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "public"
  }
}

resource "aws_subnet" "erp_crm_public2" {
  vpc_id                  = aws_vpc.erp_crm_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "erp-crm-public2"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "public"
  }
}

# Private Frontend Subnets
resource "aws_subnet" "erp_crm_private1" {
  vpc_id            = aws_vpc.erp_crm_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name        = "erp-crm-private1"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
    Tier        = "frontend"
  }
}

resource "aws_subnet" "erp_crm_private2" {
  vpc_id            = aws_vpc.erp_crm_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name        = "erp-crm-private2"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
    Tier        = "frontend"
  }
}

# Private Backend Subnets
resource "aws_subnet" "erp_crm_private3" {
  vpc_id            = aws_vpc.erp_crm_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name        = "erp-crm-private3"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
    Tier        = "backend"
  }
}

resource "aws_subnet" "erp_crm_private4" {
  vpc_id            = aws_vpc.erp_crm_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name        = "erp-crm-private4"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
    Tier        = "backend"
  }
}

# Private Database Subnets
resource "aws_subnet" "erp_crm_private5" {
  vpc_id            = aws_vpc.erp_crm_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name        = "erp-crm-private5"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
    Tier        = "database"
  }
}

resource "aws_subnet" "erp_crm_private6" {
  vpc_id            = aws_vpc.erp_crm_vpc.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name        = "erp-crm-private6"
    Component   = "subnet"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
    Tier        = "database"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "erp_crm_nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.erp_crm_igw]

  tags = {
    Name        = "erp-crm-nat-eip"
    Component   = "elasticip"
    Environment = var.environment
    Project     = var.project_name
  }
}

# NAT Gateway
resource "aws_nat_gateway" "erp_crm_nat" {
  allocation_id = aws_eip.erp_crm_nat_eip.id
  subnet_id     = aws_subnet.erp_crm_public1.id
  depends_on    = [aws_internet_gateway.erp_crm_igw]

  tags = {
    Name        = "erp-crm-nat"
    Component   = "natgateway"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public Route Table
resource "aws_route_table" "erp_crm_public_rt" {
  vpc_id = aws_vpc.erp_crm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.erp_crm_igw.id
  }

  tags = {
    Name        = "erp-crm-public-rt"
    Component   = "routetable"
    Environment = var.environment
    Project     = var.project_name
    Type        = "public"
  }
}

# Private Route Table
resource "aws_route_table" "erp_crm_private_rt" {
  vpc_id = aws_vpc.erp_crm_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.erp_crm_nat.id
  }

  tags = {
    Name        = "erp-crm-private-rt"
    Component   = "routetable"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
  }
}

# Route Table Associations - Public Subnets
resource "aws_route_table_association" "erp_crm_public1_rta" {
  subnet_id      = aws_subnet.erp_crm_public1.id
  route_table_id = aws_route_table.erp_crm_public_rt.id
}

resource "aws_route_table_association" "erp_crm_public2_rta" {
  subnet_id      = aws_subnet.erp_crm_public2.id
  route_table_id = aws_route_table.erp_crm_public_rt.id
}

# Route Table Associations - Private Subnets
resource "aws_route_table_association" "erp_crm_private1_rta" {
  subnet_id      = aws_subnet.erp_crm_private1.id
  route_table_id = aws_route_table.erp_crm_private_rt.id
}

resource "aws_route_table_association" "erp_crm_private2_rta" {
  subnet_id      = aws_subnet.erp_crm_private2.id
  route_table_id = aws_route_table.erp_crm_private_rt.id
}

resource "aws_route_table_association" "erp_crm_private3_rta" {
  subnet_id      = aws_subnet.erp_crm_private3.id
  route_table_id = aws_route_table.erp_crm_private_rt.id
}

resource "aws_route_table_association" "erp_crm_private4_rta" {
  subnet_id      = aws_subnet.erp_crm_private4.id
  route_table_id = aws_route_table.erp_crm_private_rt.id
}

resource "aws_route_table_association" "erp_crm_private5_rta" {
  subnet_id      = aws_subnet.erp_crm_private5.id
  route_table_id = aws_route_table.erp_crm_private_rt.id
}

resource "aws_route_table_association" "erp_crm_private6_rta" {
  subnet_id      = aws_subnet.erp_crm_private6.id
  route_table_id = aws_route_table.erp_crm_private_rt.id
}
