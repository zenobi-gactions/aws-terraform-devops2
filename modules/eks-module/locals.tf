locals {
  owners      = var.business_divsion
  name        = "${var.business_divsion}-${var.cluster_name}"
  common_tags = {
    owners      = local.owners  }
  eks_name = "dml-eks-cluster" # "${local.name}"
}

# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "dml"
}

# Cluster Name
variable "cluster_name" {
  type = string
  default = "eks-cluster"
}

