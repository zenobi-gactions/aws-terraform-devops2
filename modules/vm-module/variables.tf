variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
  default = "module.network-module.private_subnet_ids[0]"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
  default = "module.network.security_group_id"
}

variable "aws_instance_id" {
  description = "AWS Instance ID"
  type        = string
}

variable "network_interface_id" {
  description = "Network Interface ID"
  type        = string
}

variable "ami_id_ubuntu" {
  description = "AMI ID for Ubuntu"
  type        = string
  default = "ami-0a0e5d9c7acc336f1"
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
  default = "t3.large"
}

variable "name" {
  type = string
  default = "dml-demo"
}

variable "linux-keypair" {
  type = string
  default = "linux-key"
}