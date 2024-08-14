provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
}

# EKS Cluster Autoscaler Helm Release
resource "helm_release" "cluster_autoscaler" {
  name       = "${var.cluster_name}-cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
 # version    = "9.13.0" # Example version, ensure compatibility with your k8s version
  namespace  = "kube-system"
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
  depends_on = [module.eks]  # Updated dependency to wait for the EKS module
}

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
