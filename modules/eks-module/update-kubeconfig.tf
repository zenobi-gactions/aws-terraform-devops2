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
