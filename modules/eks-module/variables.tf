variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default = "module.network-module.vpc_id"
}
# variable "subnet_ids" {
#   description = "A list of subnet IDs for the EKS cluster"
#   type        = list(string)
# }

variable "business_division" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "dml"
}
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default = [ "module.network-module.public_subnet_ids" ]
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
    default = [ "module.network-module.private_subnet_ids" ]

}

variable "security_group_id" {
  description = "Security group ID for EKS"
  type        = string
  default = "module.network-module.security_group_id"
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

variable "node_group_max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 1
}

# AWS Account ID
variable "aws_account_id" {
  description = "AWS User Account ID"
  type        = string
  default     = "778805653184"
}

# AWS Account Name
variable "aws_account_name" {
  description = "AWS User Account name"
  type        = string
  default     = "andy"
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file."
  type        = string
  default     = "~/.kube/config"
}

# variable "kube-namespace" {
#   description = "Kubernetes namespace to deploy the AWS Load Balancer Controller into."
#   type        = string
#   default     = "kube-system"
# }

variable "grafana_admin_password" {
  description = "Admin password for Grafana."
  type        = string
  default     = "password"
}

variable "eks_managed_node_group_defaults" {
  type = object({
    ami_type  = string
    disk_size = number
    iam_role_arn = string  # Ensure this is declared as a string
  })
}

variable "iam_username" {
  type = string
  default = "admin"
}

variable "iam_role_name" {
  type = string
  default = "eks_user_role"
}