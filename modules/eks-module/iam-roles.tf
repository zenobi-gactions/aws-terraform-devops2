# IAM Role for EKS Cluster
# This role is assumed by the EKS control plane to manage the cluster.
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.${var.aws_region}.amazonaws.com/id/${data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}:sub": "system:serviceaccount:kube-system:${var.business_division}-aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  tags = {
    Name = "${var.cluster_name}-eks-cluster"
  }
}

# Attach AmazonEKSClusterPolicy to the EKS cluster IAM role.
resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Attach AmazonEKSVPCResourceController policy to the EKS cluster IAM role.
# This policy allows the EKS cluster to manage VPC resources like security groups.
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}


# Attach policy to allow EBS volume management by nodes.
# This policy is attached to the EKS node IAM role to allow the nodes to interact with EBS volumes.
# Attach the EKSNodesEBSManagement policy to the single IAM role
resource "aws_iam_role_policy" "eks_nodes_ebs_managed_policy" {
  name   = "EKSNodesEBSManagement"
  role   = module.eks.eks_managed_node_groups["public_nodes"].iam_role_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeAttribute",
          "ec2:DescribeInstances",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeTags",
          "ec2:CreateTags",
        ],
        Resource = "*"
      }
    ]
  })
}

# # Attach EKSNodesEBSManagement policy to the stateful node group role
# resource "aws_iam_role_policy" "eks_nodes_ebs_policy_stateful_nodes" {
#   name   = "EKSNodesEBSManagement"
#   role   = module.eks.eks_managed_node_groups["stateful_nodes"].iam_role_name
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ec2:CreateVolume",
#           "ec2:AttachVolume",
#           "ec2:DeleteVolume",
#           "ec2:DetachVolume",
#           "ec2:ModifyVolume",
#           "ec2:DescribeVolumeStatus",
#           "ec2:DescribeVolumes",
#           "ec2:DescribeVolumeAttribute",
#           "ec2:DescribeInstances",                
#           "ec2:DescribeAvailabilityZones",
#           "ec2:DescribeTags",
#           "ec2:CreateTags" 
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# EKS Node Group IAM Role
# This role is assumed by the EC2 instances in your EKS node groups.
resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-eks-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonEKSWorkerNodePolicy to the EKS node IAM role.
resource "aws_iam_role_policy_attachment" "eks_nodes_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

# Attach AmazonEKS_CNI_Policy to the EKS node IAM role.
# This policy is required for the CNI (Container Network Interface) plugin to manage network interfaces.
resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

# Attach AmazonEC2ContainerRegistryReadOnly policy to the EKS node IAM role.
# This policy allows the nodes to pull images from ECR (Elastic Container Registry).
resource "aws_iam_role_policy_attachment" "eks_registry_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Attach custom EBS CSI policy to the EKS node IAM role.
resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  # policy_arn = aws_iam_policy.ebs_csi_policy.arn
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_nodes.name
}

# Create the IAM Policy for the EBS CSI driver
# This policy allows the EBS CSI driver to manage EBS volumes.
resource "aws_iam_policy" "ebs_csi_policy" {
  name   = "AmazonEBSCSIDriverPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateSnapshot",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumeAttribute",
          "ec2:ModifyVolume",
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes",
          
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach AmazonEKSClusterPolicy to the EKS nodes IAM role.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_nodes.name
}

# Admin Role for Managing EKS
# This role is used by an IAM user to manage the EKS cluster.
resource "aws_iam_role" "eks_admin_role" {
  name = "eks_admin_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Fetch the certificate thumbprint for the OIDC provider
# The OIDC provider is used for IAM Roles for Service Accounts (IRSA).
data "tls_certificate" "oidc_cert" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# Output the thumbprint (optional)
output "thumbprint" {
  value = data.tls_certificate.oidc_cert.certificates[0].sha1_fingerprint
}

output "oidc_url" {
  value = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# Attach AmazonEKSClusterPolicy to the EKS admin role.
resource "aws_iam_role_policy_attachment" "eks_admin_policy" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach AmazonEKS_CNI_Policy to the EKS admin role.
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Module for creating the admin-user with all necessary IAM roles and policies
# This module creates an IAM user named "admin-user".
module "admin_user_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.3.1"

  name                          = "admin-user"
  create_iam_access_key         = false
  create_iam_user_login_profile = false

  force_destroy = true
}

# Module for creating the EKS Admin IAM role
# This module creates an IAM role that can be assumed by IAM users for managing the EKS cluster.
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

data "aws_caller_identity" "current" {}

# IAM Policy to allow access to EKS and related services
# This module creates an IAM policy that grants permissions to manage EKS and related services.
module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [ 
          "iam:ListRoles",
          "eks:*",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# IAM Policy to allow assuming the EKS Admin role
# This module creates an IAM policy that allows users to assume the EKS Admin role.
module "allow_assume_eks_admins_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-assume-eks-admin-iam-role"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = "${module.eks_admins_iam_role.iam_role_arn}"
      },
    ]
  })
}

# IAM Group for EKS Admins
# This module creates an IAM group for EKS admins and attaches the necessary policies.
module "eks_admins_iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.3.1"
  name                              = "eks-admins-group"
  attach_iam_self_management_policy = false
  create_group                      = true
  group_users                       = [
    module.admin_user_iam_user.iam_user_name, 
    data.aws_iam_user.existing_admin_user.user_name
  ]
  custom_group_policy_arns          = [module.allow_assume_eks_admins_iam_policy.arn]
}

# Ensure the existing "admin" user is added to the same IAM group
# This resource manages the membership of users in the EKS admins group.
resource "aws_iam_group_membership" "admin_group_membership" {
  name  = "admin_group_membership"
  group = module.eks_admins_iam_group.group_name
  users = [
    data.aws_iam_user.existing_admin_user.user_name,
    module.admin_user_iam_user.iam_user_name
  ]
}


# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = <<YAML
#     - rolearn: arn:aws:iam::${var.aws_account_id}:role/${var.iam_role_name}
#       username: ${var.iam_username}
#       groups:
#         - system:masters
#     YAML
#   }

#   lifecycle {
#     ignore_changes = [
#       data["mapRoles"],
#       data["mapUsers"]
#     ]
#   }
# }
####################
resource "kubectl_manifest" "patch_aws_auth" {
  provider = kubectl

  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::${var.aws_account_id}:role/${var.iam_role_name}
      username: ${var.iam_username}
      groups:
        - system:masters
YAML
  depends_on = [
      aws_iam_role.eks_nodes,         # Ensure the IAM role is created first
      module.eks                      # Ensure the EKS cluster is fully created
    ]
}
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # token                  = data.aws_eks_cluster_auth.eks_cluster_auth.name
  exec {
    # api_version = "client.authentication.k8s.io/v1alpha1"
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
# data "aws_eks_cluster" "eks_cluster" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "eks_cluster_auth" {
#   name = module.eks.cluster_name
# }
# ####################

resource "aws_iam_policy" "eks_access_policy" {
  name        = "EKSAccessPolicy"
  description = "Policy for EKS Cluster access"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:AccessKubernetesApi"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_access_policy_attachment" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = aws_iam_policy.eks_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ssm_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodes.name
}
resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

