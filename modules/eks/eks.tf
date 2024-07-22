# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${terraform.workspace}-vtech-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "${terraform.workspace}-vtech-eks-cluster"
  }
}

# IAM Role Policy Attachments for Cluster
resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Create EKS Cluster
resource "aws_eks_cluster" "vtech-cluster" {
  name     = "${terraform.workspace}-vtech-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [var.public_subnet_id, var.private_subnet_id,]
  }
  tags = {
    Name = "${terraform.workspace}-vtech-eks-cluster"
  }
  depends_on = [aws_iam_role_policy_attachment.eks_policy_attachment]
}