variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# variable "instance_type" {
#   description = "The type of instance to be created"
#   type        = string
#   default     = "t2.large"
# }

# variable "ami_id_ubuntu" {
#   description = "AMI ID for Ubuntu"
#   type        = string
#   default     = "ami-0a0e5d9c7acc336f1"
# }

variable "my_ip_address" {
  description = "Your IP address with a /32 subnet mask"
  type        = string
  default     = "146.85.138.40/32"
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

variable "aws_instance_id" {
  description = "This defines the Ubuntu Linux ID"
  type        = string
  default     = "aws_instance.build-server.id"
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
  default     = "aws_subnet.public_subnet.id"
}

variable "aws_network_interface_ids" {
  description = "The ID of the network interface to attach to the instance"
  type        = string
  default     = "aws_network_interface.public.id"
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t2.large"
}

variable "ami_id_ubuntu" {
  description = "Ubuntu Server 22.04 LTS (HVM),EBS General Purpose (SSD) Volume Type."
  type        = string
  default     = "ami-0a0e5d9c7acc336f1"
}
