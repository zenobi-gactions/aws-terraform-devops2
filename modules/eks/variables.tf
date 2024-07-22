variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

# variable "subnet_ids" {
#   description = "A list of subnet IDs for the EKS cluster"
#   type        = list(string)
# }

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "node_instance_type" {
  description = "The instance type for the EKS node group."
  type        = string
  default     = "t2.medium"
}

variable "node_capacity_type" {
  description = "The node type for the EKS node group."
  type        = string
  default     = "ON_DEMAND"
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
