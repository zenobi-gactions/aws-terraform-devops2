data "aws_ami" "eks" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.30-v*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["602401143452"] # Amazon EKS AMI owner ID
}

# Reference the existing admin IAM user without creating it
data "aws_iam_user" "existing_admin_user" {
  user_name = "admin"
}
