# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_nodes" {
  name = "${terraform.workspace}-vtech-eks-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy attachment to nodegroup
resource "aws_iam_role_policy_attachment" "eks_nodes_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}
resource "aws_iam_role_policy_attachment" "eks_registry_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}
# EKS Node Group
resource "aws_eks_node_group" "vtech-cluster" {
  cluster_name    = aws_eks_cluster.vtech-cluster.name
  node_group_name = "${terraform.workspace}-vtech-eks-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [var.private_subnet_id, var.public_subnet_id]

  capacity_type = var.node_capacity_type
  instance_types = [var.node_instance_type]
    scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }
    update_config {
    max_unavailable = 1
  } 
  labels = {
    node = "${terraform.workspace}-vtech-eks-node"
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_registry_policy_attachment,
  ]
}