# Install AWS EBS CSI Driver using Helm
resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.18.0"
  create_namespace = false
}

# Create a StorageClass that uses the AWS EBS CSI Driver
resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner  = "ebs.csi.aws.com"
  reclaim_policy       = "Delete"
  volume_binding_mode  = "WaitForFirstConsumer"
  parameters = {
    type = "gp2"
  }
  depends_on = [helm_release.aws_ebs_csi_driver]  # Ensure the driver is installed first
}
