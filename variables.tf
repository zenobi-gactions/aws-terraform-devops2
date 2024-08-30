variable "public_subnet_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "VPC Name to deploy to"
  type        = string
  default     = "dml-vpc"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block ID"
  type        = string
  default     = "10.0.0.0/16"
}
variable "aws_instance_id" {
  description = "AWS Instance ID"
  type        = string
  default     = "aws_instance.build-server.id"
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
  default     = "aws_subnet.public_subnet.id"
}

variable "network_interface_id" {
  description = "Network Interface ID"
  type        = string
  default     = "module.network-module.network_interface_id"
}

variable "cluster_name" {
  type    = string
  default = "dml"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = "aws_vpc.vpc.id"
}

variable "availability_zones" {
  description = "VPC Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "node_group_desired_size" {
  description = "Desired size of the node group"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 3
}

