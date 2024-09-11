resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.monitoring.id 
  create_namespace = false
  #  version          = "51.3.0"
  values = [
    # file("values.yaml")
    file("${path.module}/kubernetes-yaml-files/prometheus-values.yaml")
  ]
  timeout = 600
  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }
  set {
    name  = "alertmanager.enabled"
    value = "true"
  }
  set {
    name  = "server.persistentVolume.enabled"
    value = "false"
  }
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
  depends_on = [
    # time_sleep.wait_for_kubernetes,
    kubernetes_namespace.monitoring,
  ]
}