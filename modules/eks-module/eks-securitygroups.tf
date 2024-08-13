# Security Group Data Source
data "aws_security_group" "eks_cluster_sg" {
  id = module.eks.cluster_security_group_id
}

# Security Group Rule
resource "aws_security_group_rule" "eks_custom_port" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = data.aws_security_group.eks_cluster_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group associated with your node group allows SSH access.
resource "aws_security_group" "eks_nodegroup_sg" {
  name_prefix = "${var.cluster_name}-node-group-sg"
  vpc_id      = var.vpc_id  # Changed from module.network-module.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this to your IP range for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
