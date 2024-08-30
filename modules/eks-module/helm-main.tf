
# resource "kubernetes_manifest" "storage_class_gp2_immediate" {
#   manifest = {
#     apiVersion = "storage.k8s.io/v1"
#     kind       = "StorageClass"
#     metadata = {
#       name = "gp2-immediate"
#     }
#     provisioner = "kubernetes.io/aws-ebs"
#     parameters = {
#       type   = "gp2"
#       fsType = "ext4"
#     }
#     reclaimPolicy       = "Retain"
#     volumeBindingMode   = "Immediate"
#   }
# }

# resource "null_resource" "apply_grafana_crd" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ./modules/eks-module/stoage-grafana/crd-grafana.yaml --kubeconfig ${var.kubeconfig_path}"
#   }

#   depends_on = [null_resource.update_kubeconfig]
# }

# resource "null_resource" "apply_storage_class" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f  ./modules/eks-module/stoage-grafana/storage-class.yaml --kubeconfig ${var.kubeconfig_path}"
#   }

#   depends_on = [null_resource.update_kubeconfig]
# }

# # Kubernetes Namespace for ArgoCD
# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
#   depends_on = [
#     module.eks
#   ]
# }

# # Helm Release for ArgoCD
# resource "helm_release" "argo_cd" {
#   name             = "argo-cd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   version          = "5.24.1"
#   namespace        = kubernetes_namespace.argocd.metadata[0].name
#   create_namespace = false
#   skip_crds        = true

#   set {
#     name  = "server.service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "server.ingress.enabled"
#     value = "false"
#   }

#   depends_on = [
#     module.eks,
#     kubernetes_namespace.argocd
#   ]
# }

# Helm Release for Cert-Manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.11"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

# # Helm Release for Prometheus
# resource "helm_release" "prometheus" {
#   name             = "prometheus"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "prometheus"
#   version          = "15.0.1"
#   namespace        = kubernetes_namespace.monitoring.metadata[0].name
#   create_namespace = false
#   timeout          = 600

#   set {
#     name  = "server.service.type"
#     value = "LoadBalancer"
#   }
#   set {
#     name  = "alertmanager.enabled"
#     value = "true"
#   }
#   set {
#     name  = "alertmanager.persistentVolume.storageClass"
#     value = var.prometheus_storage_class
#   }
#   set {
#     name  = "server.persistentVolume.storageClass"
#     value = var.prometheus_storage_class
#   }
#   set {
#     name  = "server.persistentVolume.size"
#     value = var.prometheus_server_pv_size
#   }
#   set {
#     name  = "alertmanager.persistentVolume.size"
#     value = var.alertmanager_pv_size
#   }
#   set {
#     name  = "server.persistentVolume.enabled"
#     value = "false"
#   }
#   set {
#     name  = "alertmanager.persistentVolume.enabled"
#     value = "false"
#   }
#   set {
#     name  = "server.resources.requests.memory"
#     value = var.server_requests_memory
#   }
#   set {
#     name  = "server.resources.requests.cpu"
#     value = var.server_requests_cpu
#   }
#   set {
#     name  = "alertmanager.resources.requests.memory"
#     value = var.alertmanager_requests_memory
#   }
#   set {
#     name  = "alertmanager.resources.requests.cpu"
#     value = var.alertmanager_requests_cpu
#   }

#   depends_on = [
#     kubernetes_namespace.monitoring,
#   ]
# }

# # Ensure CRDs are installed first
# resource "kubernetes_manifest" "grafana_crds" {
#   manifest = {
#     apiVersion = "apiextensions.k8s.io/v1"
#     kind       = "CustomResourceDefinition"
#     metadata = {
#       name = "grafanadashboards.integreatly.org"
#     }
#     spec = {
#       group   = "integreatly.org"
#       names   = {
#         plural   = "grafanadashboards"
#         singular = "grafanadashboard"
#         kind     = "GrafanaDashboard"
#       }
#       scope = "Namespaced"
#       versions = [{
#         name    = "v1alpha1"
#         served  = true
#         storage = true
#         schema = {
#           openAPIV3Schema = {
#             type = "object"
#             properties = {
#               spec = {
#                 type = "object"
#                 properties = {
#                   json = {
#                     type = "string"
#                   }
#                   url = {
#                     type = "string"
#                   }
#                 }
#               }
#             }
#           }
#         }
#       }]
#     }
#   }

#   depends_on = [module.eks]
# }

# # Helm Release for Grafana
# resource "helm_release" "grafana" {
#   name             = "grafana"
#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "grafana"
#   version          = "8.4.4"
#   namespace        = kubernetes_namespace.monitoring.metadata[0].name
#   create_namespace = false

#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "adminPassword"
#     value = "admin" # Change to a secure password
#   }

#   # Disable PodSecurityPolicy if the chart supports it
#   set {
#     name  = "podSecurityPolicy.enabled"
#     value = "false"
#   }

#   # Disable the Grafana test framework which might be causing the issue
#   set {
#     name  = "testFramework.enabled"
#     value = "false"
#   }

#   # Explicitly disable the PSP for testFramework if necessary
#   set {
#     name  = "testFramework.podSecurityPolicy.enabled"
#     value = "false"
#   }

#   depends_on = [
#     helm_release.prometheus,
#     kubernetes_namespace.monitoring
#   ]
# }
