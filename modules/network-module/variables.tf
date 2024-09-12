variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = "aws_vpc.vpc.id"
}

variable "my_ip_address" {
  description = "Your IP address with a /32 subnet mask"
  type        = string
  default     = "146.85.139.194/32"
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "public_subnet" {
  description = "The name of the public subnet"
  type        = string
  default     = "aws_subnet.public_subnet"
}

variable "security_group_id" {
  type    = string
  default = "aws_security_group.cluster.id"
}

variable "aws_instance_id" {
  description = "This defines the Ubuntu Linux ID"
  type        = string
}

variable "subnet_id" {
  type    = string
  default = "aws_subnet.public_subnet.id"
}

variable "network_interface_id" {
  description = "This defines the Network Interface ID"
  type        = string
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-123abc", "subnet-456def"]  # Ensure these are in different AZs
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "dml-vpc"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_database_subnets" {
  description = "VPC Database Subnets"
  type        = list(string)
  default     = ["10.0.151.0/24", "10.0.152.0/24"]
}

variable "vpc_create_database_subnet_group" {
  description = "VPC Create Database Subnet Group"
  type        = bool
  default     = true
}

variable "vpc_create_database_subnet_route_table" {
  description = "VPC Create Database Subnet Route Table"
  type        = bool
  default     = true
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "stage"
}

variable "aws_account_id" {
  description = "AWS User Account ID"
  type        = string
  default     = "778805653184"
}

variable "business_division" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "dml"
}

################################################################
# Input Variables

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

