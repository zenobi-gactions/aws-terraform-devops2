provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

provider "kubernetes" {
  alias = "eks"
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  insecure               = false
}
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config" # Optional fallback
#   }
# }

provider "kubernetes" {
  config_path = "~/.kube/config"
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  insecure               = false
}


# provider "helm" {
#   kubernetes_host                   = data.aws_eks_cluster.eks_cluster.endpoint
#   kubernetes_cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#   kubernetes_token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
#   kubernetes_insecure               = false
# }



provider "helm" {
   kubernetes = {
    config_path = "~/.kube/config"
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
}



