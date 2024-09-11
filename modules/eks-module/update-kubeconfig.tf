# Define a null_resource to run the update-kubeconfig command
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
  }

  # Ensure this resource runs only if it has changed
  triggers = {
    cluster_name = module.eks.cluster_name
  }
}

resource "null_resource" "clean_up_argocd_resources" {
  triggers = {
    eks_cluster_name = module.eks.cluster_name
  }
  provisioner "local-exec" {
    command = <<-EOT
      kubeconfig=/tmp/tf.clean_up_argocd.kubeconfig.yaml
      aws eks update-kubeconfig --name ${self.triggers.eks_cluster_name} --kubeconfig $kubeconfig
      rm -f /tmp/tf.clean_up_argocd_resources.err.log
      kubectl --kubeconfig $kubeconfig get Application -A -o name | xargs -I {} kubectl --kubeconfig $kubeconfig -n argocd patch -p '{"metadata":{"finalizers":null}}' --type=merge {} 2> /tmp/tf.clean_up_argocd_resources.err.log || true
      rm -f $kubeconfig
    EOT
    interpreter = ["bash", "-c"]
    when        = destroy
  }
}


# resource "null_resource" "clean_up_argocd_resources" {
#   triggers = {
#     eks_cluster_name = module.eks.cluster_name
#   }
#   provisioner "local-exec" {
#     command     = <<-EOT
#       kubeconfig=/tmp/tf.clean_up_argocd.kubeconfig.yaml
#       aws eks update-kubeconfig --name ${self.triggers.eks_cluster_name} --kubeconfig $kubeconfig
#       rm -f /tmp/tf.clean_up_argocd_resources.err.log
#       kubectl --kubeconfig $kubeconfig get Application -A -o name | xargs -I {} kubectl --kubeconfig $kubeconfig -n argocd patch -p '{"metadata":{"finalizers":null}}' --type=merge {} 2> /tmp/tf.clean_up_argocd_resources.err.log || true
#       rm -f $kubeconfig
#     EOT
#     interpreter = ["bash", "-c"]
#     when        = destroy
#   }
# }
