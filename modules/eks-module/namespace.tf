# Resource: k8s monitoring namespace creation
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Resource: k8s argocd namespace creation
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [ time_sleep.wait_for_kubernetes ]
}

# Resource: k8s dev namespace creation
resource "kubernetes_namespace_v1" "k8s_dev" {
  metadata {
    name = "dev"
  }
}

# Introduces a delay to allow the EKS cluster and associated resources to fully initialize before proceeding.
# This ensures that the Kubernetes cluster is ready for subsequent operations that may depend on it.
resource "time_sleep" "wait_for_kubernetes" {
  depends_on = [
    module.eks
  ]
  create_duration = "20s"
}

