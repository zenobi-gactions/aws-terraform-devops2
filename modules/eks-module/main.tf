# EKS Cluster module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"
  
  cluster_name    = "dml-eks-cluster"
  cluster_version = "1.32"
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 30
  }
  
  enable_irsa = true

  eks_managed_node_groups = {
    public_nodes = {
      name               = "public-node-group"
      instance_types     = ["t3.large"]
      desired_size       = 2
      min_size           = 1
      max_size           = 3
      capacity_type      = "ON_DEMAND"
      subnet_ids         = var.public_subnet_ids
      security_group_ids = [var.security_group_id]
      key_name           = "eks-terraform-key"
      iam_role_arn       = aws_iam_role.eks_nodes.arn
      labels = {
        role = "general"
      }
    }
    
    # stateful_nodes = {
    #   name               = "stateful-node-group"
    #   instance_types     = ["m5.large"]
    #   desired_size       = 1
    #   min_size           = 1
    #   max_size           = 3
    #   capacity_type      = "ON_DEMAND"
    #   subnet_ids         = var.public_subnet_ids
    #   security_group_ids = [var.security_group_id]
    #   key_name           = "eks-terraform-key"
    #   iam_role_arn       = aws_iam_role.eks_nodes.arn
    #   labels = {
    #     role = "stateful"
    #   }
    # }
  }

  tags = {
    Environment = "dev"
  }
}












# # Create EKS Cluster
# resource "aws_eks_cluster" "eks_cluster" {
#   name     = local.eks_name  #"${local.eks_name}"
#   role_arn = aws_iam_role.eks_cluster.arn

#   vpc_config {
#     subnet_ids = var.subnet_ids
#   }

#   tags = {
#     Name = local.eks_name # "${local.eks_name}"
#   }
#   enabled_cluster_log_types = ["api", "audit", "authenticator"]
#   depends_on = [aws_iam_role_policy_attachment.eks_policy_attachment]
# }

# resource "aws_launch_template" "public_nodes" {
#   name_prefix = "${local.eks_name}-node-group"

#   # Include remote access configuration here
#   key_name = "eks-terraform-key"

# }

# data "aws_iam_policy" "ebs_csi_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

