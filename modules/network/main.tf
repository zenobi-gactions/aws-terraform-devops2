# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = local.cidr_blocks[terraform.workspace]
  enable_dns_hostnames = true
  tags = {
    Name = "${terraform.workspace}-project-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  count = length(local.public_subnet_cidr[terraform.workspace])

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_subnet_cidr[terraform.workspace][count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.availability_zones[terraform.workspace][count.index]

  tags = {
    Name = "${terraform.workspace}-public-subnet-${count.index}"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  count = length(local.private_subnet_cidr[terraform.workspace])

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.private_subnet_cidr[terraform.workspace][count.index]
  map_public_ip_on_launch = false
  availability_zone       = local.availability_zones[terraform.workspace][count.index]

  tags = {
    Name = "${terraform.workspace}-private-subnet-${count.index}"
  }
}

# Create Security Group
resource "aws_security_group" "cluster" {
  vpc_id = aws_vpc.vpc.id  # Ensure this is correctly referenced
  name   = "${terraform.workspace}-security-group"
  dynamic "ingress" {
    for_each = local.security_group_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${terraform.workspace}-security-group"
  }
}

# Create Internet Gateway for VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${terraform.workspace}-internet-gateway"
  }
}

# Create Elastic IP Address
resource "aws_eip" "public_ip" {
  count = length(aws_network_interface.public)  # Ensure count matches the number of network interfaces

  domain = "vpc"
  network_interface = aws_network_interface.public[count.index].id
  
  tags = {
    Name = "${terraform.workspace}-public-ip-${count.index}"
  }
}

# AWS Network Interface
resource "aws_network_interface" "public" {
  count             = length(local.public_subnet_ids)
  subnet_id         = local.public_subnet_ids[count.index]
  private_ips       = [cidrhost(local.public_subnet_cidr[terraform.workspace][count.index], 10)]  # Ensure the IP is within the subnet's CIDR range
  security_groups   = [aws_security_group.cluster.id]

  tags = {
    Name = "${terraform.workspace}-public-interface-${count.index}"
  }
  depends_on = [aws_subnet.public_subnet]
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${terraform.workspace}-public-route-table"
  }
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${terraform.workspace}-private-route-table"
  }
}

# Associate Public subnets with Public route table
resource "aws_route_table_association" "public_association" {
  count = length(aws_subnet.public_subnet.*.id)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private subnets with Private route table
resource "aws_route_table_association" "private_association" {
  count = length(aws_subnet.private_subnet.*.id)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Data source for availability zones
data "aws_availability_zones" "available" {}
