variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
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
  default     = "module.network.network_interface_id"
}

# variable "instance_type" {
#   description = "Type of the instance"
#   type        = string
#   default = "t2.large"
# }

# variable "ami_id_ubuntu" {
#   description = "AMI ID for Ubuntu"
#   type        = string
#   default     = "ami-0a0e5d9c7acc336f1"
# }

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
