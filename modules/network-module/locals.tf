locals {
  # Unified VPC Configuration
  vpc_name       = var.vpc_name
  cidr_block     = var.vpc_cidr_block  # Single CIDR block for the VPC

  public_subnet_cidr  = var.vpc_public_subnets  # List of CIDR blocks for public subnets
  private_subnet_cidr = var.vpc_private_subnets  # List of CIDR blocks for private subnets

  availability_zones = ["us-east-1a", "us-east-1b"]  # Use two availability zones

  # Security group rules
  security_group_rules = [
    {
      name        = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      name        = "HTTP access"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      name        = "HTTPS access"
      from_port   = 9443
      to_port     = 9443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      name        = "App Port 8081"
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      name        = "App Port 8080"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      name        = "App Port 9000"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      name        = "App Port 3000"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
