
resource "kubernetes_cluster_role" "eks_admin" {
  metadata {
    name = "eks-admin"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets", "replicasets"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "eks_admin_binding" {
  metadata {
    name = "eks-admin-binding"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.eks_admin.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "User"
    name      = "arn:aws:iam::${var.aws_account_id}:user/${var.aws_account_name}"
    api_group = "rbac.authorization.k8s.io"
  }
}