provider "aws" {
  region = var.aws_region
}

# EKS Cluster Autoscaler Helm Release
resource "helm_release" "cluster_autoscaler" {
  name       = "${terraform.workspace}-vtech-cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.10.7"
  namespace = "kube-system"
  values = [
    yamlencode({
      rbac = {
        serviceAccount = {
          name = "cluster-autoscaler"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.eks_cluster_autoscaler.arn
          }
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.vtech-cluster]
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name = "${terraform.workspace}-vtech-eks-load-balancer-controller-role"
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
  name       = "${terraform.workspace}-eks-load-balancer-controller"
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
    value = aws_eks_cluster.vtech-cluster.name
  }
  set {
    name  = "serviceAccount.name"
    value = "${terraform.workspace}-aws-load-balancer-controller"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller_role.arn
  }
    depends_on = [aws_eks_cluster.vtech-cluster]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.vtech-cluster.name
}
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.vtech-cluster.name
}
