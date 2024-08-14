variable "admin_password" {
  description = "The admin password for Grafana"
  type        = string
  default     = "admin" # Change this to a secure value
}

variable "prometheus_storage_class" {
  description = "The storage class for Prometheus server and Alertmanager"
  type        = string
  default     = "gp2-immediate"
}

variable "prometheus_server_pv_size" {
  description = "The size of the persistent volume for Prometheus server"
  type        = string
  default     = "8Gi"
}

variable "alertmanager_pv_size" {
  description = "The size of the persistent volume for Alertmanager"
  type        = string
  default     = "8Gi"
}

variable "server_requests_memory" {
  description = "Memory requests for Prometheus server"
  type        = string
  default     = "1Gi"
}

variable "server_requests_cpu" {
  description = "CPU requests for Prometheus server"
  type        = string
  default     = "500m"
}

variable "alertmanager_requests_memory" {
  description = "Memory requests for Alertmanager"
  type        = string
  default     = "512Mi"
}

variable "alertmanager_requests_cpu" {
  description = "CPU requests for Alertmanager"
  type        = string
  default     = "250m"
}
