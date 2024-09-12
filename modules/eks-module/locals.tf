locals {
  owners      = var.business_division
  name        = "${var.business_division}-${var.cluster_name}"
  common_tags = {
    owners      = local.owners  }
  eks_name = "dml-eks-cluster" # "${local.name}"
}

# Business Division


# Cluster Name
variable "cluster_name" {
  type = string
  default = "eks-cluster"
}

