resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  count                = length(var.public_subnet_cidr)
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = element(var.public_subnet_cidr, count.index)
  availability_zone    = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                = length(var.private_subnet_cidr)
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = element(var.private_subnet_cidr, count.index)
  availability_zone    = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index}"
  }
}


resource "aws_security_group" "cluster" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.vpc_name}-security-group"

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
    Name = "${local.vpc_name}-security-group"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.vpc_name}-internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${local.vpc_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  count         = length(aws_subnet.public_subnet)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.vpc_name}-private-route-table"
  }
}

resource "aws_route_table_association" "private_association" {
  count         = length(aws_subnet.private_subnet)
  subnet_id     = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
