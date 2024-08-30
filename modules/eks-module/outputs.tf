# Output the EKS cluster details
output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

# Removing or adjusting the node group ID output if not available
output "eks_node_group_id" {
  description = "The ID of the EKS node group"
  value       = module.eks.eks_managed_node_groups["public_nodes"]
}

# Removing or adjusting the instance type output if not available
output "node_instance_type" {
  value = module.eks.eks_managed_node_groups["public_nodes"]
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller_role.arn
}

output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}

output "oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

 output "prometheus_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value       = helm_release.prometheus.status
}

output "grafana_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value       = helm_release.grafana.metadata
}

output "argo_cd_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value       = helm_release.argo_cd.metadata
}

output "eks_nodes_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}