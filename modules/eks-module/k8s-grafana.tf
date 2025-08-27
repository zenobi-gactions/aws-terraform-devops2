# Introduce a delay before deploying Grafana
resource "null_resource" "pre_helm_delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [
    kubernetes_storage_class_v1.ebs_sc,
    kubernetes_config_map.grafana-dashboards,
    kubernetes_namespace.monitoring,
  ]
}

# Deploy Grafana using Helm
resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "monitoring"
  create_namespace = false
  version          = "6.57.4"
  wait             = true
  timeout          = 300
  force_update     = true
values = [
  file("${path.root}/modules/eks-module/kubernetes-yaml-files/grafana-values.yaml"),
  yamlencode({
    database = {
      type   = "mysql"
      host   = "mysql.monitoring.svc.cluster.local:3306"
      name   = "grafana"
      user   = "grafana"
      password = {
        secretName = "grafana-secret"
        secretKey  = "password"
      }
    }
    sidecar = {
      dashboards = {
        enabled = true
        label   = "grafana_dashboard"
      }
    }
  })
]
set = [
  {
    name  = "service.type"
    value = "LoadBalancer"
  },
  {
    name  = "persistence.storageClassName"
    value = "ebs-sc"
  },
  {
    name  = "image.tag"
    value = "9.5.2"
  },
  {
    name  = "persistence.enabled"
    value = "true"
  },
  {
    name  = "persistence.size"
    value = "8Gi"
  },
  {
    name  = "persistence.accessModes[0]"
    value = "ReadWriteOnce"
  },
  {
    name  = "adminPassword"
    value = var.grafana_admin_password
  },
  {
    name  = "sidecar.dashboards.enabled"
    value = "true"
  },
  {
    name  = "sidecar.dashboards.label"
    value = "grafana_dashboard"
  },
  {
    name  = "resources.requests.memory"
    value = "256Mi"
  },
  {
    name  = "resources.requests.cpu"
    value = "100m"
  },
  {
    name  = "resources.limits.memory"
    value = "512Mi"
  },
  {
    name  = "resources.limits.cpu"
    value = "250m"
  },
  {
    name  = "plugins[0]"
    value = "grafana-piechart-panel"
  },
  {
    name  = "datasources.datasources.yaml.apiVersion"
    value = "1"
  },
  {
    name  = "datasources.datasources.yaml.datasources[0].name"
    value = "prometheus-k8s"
  },
  {
    name  = "datasources.datasources.yaml.datasources[0].type"
    value = "prometheus"
  },
  {
    name  = "datasources.datasources.yaml.datasources[0].url"
    value = "http://prometheus-k8s.monitoring.svc:9090"
  },
  {
    name  = "datasources.datasources.yaml.datasources[0].access"
    value = "proxy"
  },
  {
    name  = "datasources.datasources.yaml.datasources[0].isDefault"
    value = "true"
  },
  {
    name  = "testFramework.enabled"
    value = "false"
  }
]
  
  depends_on = [
    kubernetes_namespace.monitoring,
    null_resource.pre_helm_delay,
    # aws_lb.grafana,
    # aws_route53_record.grafana,
  ]
}

# Create ConfigMaps for dashboards using for_each
resource "kubernetes_config_map" "grafana-dashboards" {
  for_each = { for dashboard in local.dashboards : dashboard.name => dashboard }

  metadata {
    name      = each.key
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "dashboard"
    }
  }

  data = {
    "${each.value.file}" = file("${path.root}/modules/eks-module/grafana-dashboard/${each.value.file}")
  }
  depends_on = [ kubernetes_namespace.monitoring, ]
}

# Define a list of dashboards
locals {
  dashboards = [
    {
      name = "grafana-dashboards-alerting"
      file = "volume-alerting.json"
    },
    {
      name = "node"
      file = "node.json"
    },
    {
      name = "coredns"
      file = "coredns.json"
    },
    {
      name = "api"
      file = "api.json"
    },
    {
      name = "kubelet"
      file = "kubelet.json"
    },
    {
      name = "proxy"
      file = "proxy.json"
    },
    {
      name = "statefulsets"
      file = "statefulsets.json"
    },
    {
      name = "persistent-volumes"
      file = "persistent-volumes.json"
    },
    {
      name = "prometheous-overview"
      file = "prometheous-overview.json"
    },
    {
      name = "use-method-cluster"
      file = "use-method-cluster.json"
    },
    {
      name = "use-method-node"
      file = "use-method-node.json"
    },
    {
      name = "compute-resources-cluster"
      file = "compute-resources-cluster.json"
    },
    {
      name = "compute-resources-node-pods"
      file = "compute-resources-node-pods.json"
    },
    {
      name = "compute-resources-pod"
      file = "compute-resources-pod.json"
    },
    {
      name = "compute-resources-workload"
      file = "compute-resources-workload.json"
    },
    {
      name = "compute-resources-namespace-workloads"
      file = "compute-resources-namespace-workloads.json"
    },
    {
      name = "computer-resources-namespace-pods"
      file = "computer-resources-namespace-pods.json"
    },
    {
      name = "networking-namespace-pods"
      file = "networking-namespace-pods.json"
    },
    {
      name = "networking-namespace-workload"
      file = "networking-namespace-workload.json"
    },
    {
      name = "networking-cluster"
      file = "networking-cluster.json"
    },
    {
      name = "networking-pods"
      file = "networking-pods.json"
    },
    {
      name = "networking-workload"
      file = "networking-workload.json"
    },
    {
      name = "istio-control-plane"
      file = "istio-control-plane.json"
    },
    {
      name = "istio-mesh"
      file = "istio-mesh.json"
    },
    {
      name = "istio-performance"
      file = "istio-performance.json"
    },
    {
      name = "istio-service"
      file = "istio-service.json"
    },
    {
      name = "istio-workload"
      file = "istio-workload.json"
    }
  ]
}




# # other dashboard

# resource "kubernetes_config_map" "node" {
#   metadata {
#     name      = "node"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "node.json" = "${file("${path.module}/grafana-dashboard/node.json")}"
#   }
# }
# resource "kubernetes_config_map" "coredns" {
#   metadata {
#     name      = "coredns"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "coredns.json" = "${file("${path.module}/grafana-dashboard/coredns.json")}"
#   }
# }
# resource "kubernetes_config_map" "api" {
#   metadata {
#     name      = "api"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "api.json" = "${file("${path.module}/grafana-dashboard/api.json")}"
#   }
# }
# resource "kubernetes_config_map" "kubelet" {
#   metadata {
#     name      = "kubelet"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "kubelet.json" = "${file("${path.module}/grafana-dashboard/kubelet.json")}"
#   }
# }
# resource "kubernetes_config_map" "proxy" {
#   metadata {
#     name      = "proxy"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "proxy.json" = "${file("${path.module}/grafana-dashboard/proxy.json")}"
#   }
# }
# resource "kubernetes_config_map" "statefulsets" {
#   metadata {
#     name      = "statefulsets"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "statefulsets.json" = "${file("${path.module}/grafana-dashboard/statefulsets.json")}"
#   }
# }
# resource "kubernetes_config_map" "persistent-volumes" {
#   metadata {
#     name      = "persistent-volumes"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "persistent-volumes.json" = "${file("${path.module}/grafana-dashboard/persistent-volumes.json")}"
#   }
# }
# resource "kubernetes_config_map" "prometheous-overview" {
#   metadata {
#     name      = "prometheous-overview"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "prometheous-overview.json" = "${file("${path.module}/grafana-dashboard/prometheous-overview.json")}"
#   }
# }
# resource "kubernetes_config_map" "use-method-cluster" {
#   metadata {
#     name      = "use-method-cluster"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "use-method-cluster.json" = "${file("${path.module}/grafana-dashboard/use-method-cluster.json")}"
#   }
# }
# resource "kubernetes_config_map" "use-method-node" {
#   metadata {
#     name      = "use-method-node"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "use-method-node.json" = "${file("${path.module}/grafana-dashboard/use-method-node.json")}"
#   }
# }
# #compute resources dashboard
# resource "kubernetes_config_map" "compute-resources-cluster" {
#   metadata {
#     name      = "compute-resources-cluster"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "compute-resources-cluster.json" = "${file("${path.module}/grafana-dashboard/compute-resources-cluster.json")}"
#   }
# }
# resource "kubernetes_config_map" "compute-resources-node-pods" {
#   metadata {
#     name      = "compute-resources-node-pods"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "compute-resources-node-pods.json" = "${file("${path.module}/grafana-dashboard/compute-resources-node-pods.json")}"
#   }
# }
# resource "kubernetes_config_map" "compute-resources-pod" {
#   metadata {
#     name      = "compute-resources-pod"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "compute-resources-pod.json" = "${file("${path.module}/grafana-dashboard/compute-resources-pod.json")}"
#   }
# }
# resource "kubernetes_config_map" "compute-resources-workload" {
#   metadata {
#     name      = "compute-resources-workload"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "compute-resources-workload.json" = "${file("${path.module}/grafana-dashboard/compute-resources-workload.json")}"
#   }
# }
# resource "kubernetes_config_map" "compute-resources-namespace-workloads" {
#   metadata {
#     name      = "compute-resources-namespace-workloads"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "compute-resources-namespace-workloads.json" = "${file("${path.module}/grafana-dashboard/compute-resources-namespace-workloads.json")}"
#   }
# }
# resource "kubernetes_config_map" "computer-resources-namespace-pods" {
#   metadata {
#     name      = "computer-resources-namespace-pods"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "computer-resources-namespace-pods.json" = "${file("${path.module}/grafana-dashboard/computer-resources-namespace-pods.json")}"
#   }
# }

# #networking dashboard
# resource "kubernetes_config_map" "networking-namespace-pods" {
#   metadata {
#     name      = "networking-namespace-pods"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "networking-namespace-pods.json" = "${file("${path.module}/grafana-dashboard/networking-namespace-pods.json")}"
#   }
# }
# resource "kubernetes_config_map" "networking-namespace-workload" {
#   metadata {
#     name      = "networking-namespace-workload"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "networking-namespace-workload.json" = "${file("${path.module}/grafana-dashboard/networking-namespace-workload.json")}"
#   }
# }
# resource "kubernetes_config_map" "networking-cluster" {
#   metadata {
#     name      = "networking-cluster"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "networking-cluster.json" = "${file("${path.module}/grafana-dashboard/networking-cluster.json")}"
#   }
# }
# resource "kubernetes_config_map" "networking-pods" {
#   metadata {
#     name      = "networking-pods"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "networking-pods.json" = "${file("${path.module}/grafana-dashboard/networking-pods.json")}"
#   }
# }
# resource "kubernetes_config_map" "networking-workload" {
#   metadata {
#     name      = "networking-workload"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "networking-workload.json" = "${file("${path.module}/grafana-dashboard/networking-workload.json")}"
#   }
# }

# #Istio dashboard
# resource "kubernetes_config_map" "istio-control-plane" {
#   metadata {
#     name      = "istio-control-plane"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "istio-control-plane.json" = "${file("${path.module}/grafana-dashboard/istio-control-plane.json")}"
#   }
# }
# resource "kubernetes_config_map" "istio-mesh" {
#   metadata {
#     name      = "istio-mesh"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "istio-mesh.json" = "${file("${path.module}/grafana-dashboard/istio-mesh.json")}"
#   }
# }
# resource "kubernetes_config_map" "istio-performance" {
#   metadata {
#     name      = "istio-performance"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "istio-performance.json" = "${file("${path.module}/grafana-dashboard/istio-performance.json")}"
#   }
# }
# resource "kubernetes_config_map" "istio-service" {
#   metadata {
#     name      = "istio-service"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "istio-service.json" = "${file("${path.module}/grafana-dashboard/istio-service.json")}"
#   }
# }
# resource "kubernetes_config_map" "istio-workload" {
#   metadata {
#     name      = "istio-workload"
#     namespace = "monitoring"
#     labels = {
#       grafana_dashboard = "dashboard"
#     }
#   }
#   data = {
#     "istio-workload.json" = "${file("${path.module}/grafana-dashboard/istio-workload.json")}"
#   }
# }

# # resource "helm_release" "grafana" {
# #   name             = "grafana"
# #   repository       = "https://grafana.github.io/helm-charts"
# #   chart            = "grafana"
# #   namespace        = "monitoring" # kubernetes_namespace.monitor_namespace.metadata[0].name
# #   # version          = "11.1.4" #var.grafana_version
# #   create_namespace = false
  
# #   values = [
# #     file("${path.module}/kubernetes-yaml-files/grafana.values.yaml"),
# #     # yamlencode(var.settings_grafana)
# #   ]
# #   set {
# #     name  = "service.type"
# #     value = "LoadBalancer"
# #   }
# #   set {
# #     name  = "adminPassword"
# #     value = var.grafana_admin_password
# #   }
# #    # Disable PodSecurityPolicy if the chart supports it
# #   set {
# #     name  = "podSecurityPolicy.enabled"
# #     value = "false"
# #   }

# #   # Disable the Grafana test framework which might be causing the issue
# #   set {
# #     name  = "testFramework.enabled"
# #     value = "false"
# #   }

# #   # Explicitly disable the PSP for testFramework if necessary
# #   set {
# #     name  = "testFramework.podSecurityPolicy.enabled"
# #     value = "false"
# #   }
# #   depends_on = [
# #     kubernetes_namespace.monitoring,
# #     # time_sleep.wait_for_kubernetes,
# #   ]
# # }


