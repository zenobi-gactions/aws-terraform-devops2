# Local Variables
locals {
  env = terraform.workspace
}

## Network Module
module "network-module" {
  source               = "./modules/network-module"
  aws_region           = var.aws_region
  aws_instance_id      = var.aws_instance_id # module.vm-module.aws_instance_id #var.aws_instance_id
  public_subnet_id     = var.public_subnet_id             #module.public_subnet_id
  network_interface_id = var.network_interface_id
  vpc_name             = var.vpc_name
  vpc_cidr_block       = var.vpc_cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidr   = var.public_subnet_cidr  # ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr  = var.private_subnet_cidr # ["10.0.3.0/24", "10.0.4.0/24"]
}

## VM Module
# module "vm-module" {
#   source               = "./modules/vm-module"
#   public_subnet_id     = module.network-module.public_subnet_ids[0]  # Get the first subnet
#   private_subnet_id    = module.network-module.private_subnet_ids[0] # Get the first private subnet
#   vpc_id               = module.network-module.vpc_id
#   security_group_id    = module.network-module.security_group_id
#   network_interface_id = var.network_interface_id
#   aws_instance_id      = var.aws_instance_id
# }
### EKS-Cluster Requirement  --- Below 
## EKS Module
module "eks-module" {
  source                  = "./modules/eks-module"
  aws_region              = var.aws_region
  cluster_name            = var.cluster_name
  vpc_id                  = module.network-module.vpc_id
  private_subnet_ids      = module.network-module.private_subnet_ids
  public_subnet_ids       = module.network-module.public_subnet_ids
  security_group_id       = module.network-module.security_group_id
  node_group_desired_size = var.node_group_desired_size
  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
  eks_managed_node_group_defaults = {
    ami_type     = "AL2_x86_64"                         # Default Amazon Linux 2 AMI
    disk_size    = 30                                   # Default disk size (GB)
    iam_role_arn = module.eks-module.eks_nodes_role_arn # The IAM role ARN for the node group
  }
  # providers = {
  #   kubectl = kubectl
  # }
}

### EKS-Cluster Requirement  --- Above 