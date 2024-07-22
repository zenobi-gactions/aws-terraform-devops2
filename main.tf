# Local Variables
locals {
  env = terraform.workspace
}

# Network Module
module "network" {
  source               = "./modules/network"
  aws_region           = var.aws_region
  aws_instance_id      = var.aws_instance_id
  public_subnet_id     = var.public_subnet_id
  network_interface_id = var.aws_network_interface_ids
}

# VM Module
module "vm" {
  source        = "./modules/vm"
  instance_type = var.instance_type
  ami_id_ubuntu = var.ami_id_ubuntu

  public_subnet_id  = module.network.public_subnet_ids[0]
  private_subnet_id = module.network.private_subnet_ids[0]

  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  vpc_id               = module.network.vpc_id
  security_group_id    = module.network.security_group_id
  network_interface_id = module.network.aws_network_interface_ids[0]
  aws_instance_id      = var.aws_instance_id
}

# EKS Module
module "eks" {
  source                  = "./modules/eks"
  aws_region              = var.aws_region
  subnet_ids              = concat(module.network.public_subnet_ids, module.network.private_subnet_ids)
  instance_type           = var.instance_type
  node_group_desired_size = var.node_group_desired_size
  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
}

# module "eks" {
#   source = "./modules/eks"
#   cluster_name = module.eks.local_cluster_name
#   node_group_name = module.eks.local_node_group_name
# }
