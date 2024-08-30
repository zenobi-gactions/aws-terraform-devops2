# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name = "${var.cluster_name}-eks-load-balancer-controller-role"
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

# Helm release for AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.4"
  set {
    name  = "replicaCount"
    value = 1
  }
  set {
    name  = "clusterName"
    value = module.eks.cluster_name  # Updated reference
  }
  set {
    name  = "serviceAccount.name"
    value = "${var.cluster_name}-aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller_role.arn
  }
  depends_on = [module.eks]
}