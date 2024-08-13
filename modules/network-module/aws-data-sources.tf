# Data sources for dynamically retrieving subnet IDs based on tags, AZs, or CIDR blocks
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["private-subnet-*"]  # Adjust this tag as needed
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet-*"]  # Adjust this tag as needed
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Use the dynamic subnet IDs in your configuration
locals {
  private_subnet_ids = data.aws_subnets.private.ids
  public_subnet_ids  = data.aws_subnets.public.ids
}
