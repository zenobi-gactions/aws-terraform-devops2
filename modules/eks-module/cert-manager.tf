# Helm Release for Cert-Manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.11.5"

  set = [
    {
    name  = "installCRDs"
    value = "true"
  },
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}
