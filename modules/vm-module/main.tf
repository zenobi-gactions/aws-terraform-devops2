resource "aws_instance" "build-server" {
  ami                         = var.ami_id_ubuntu #var.ami_id_ubuntu
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = "${var.linux-keypair}-keypair"
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.public_subnet_id  # Single public subnet ID
  user_data = file("${path.module}/app-scripts/install.sh")
  tags = {
    Name = "jenkins-server"
  }
  root_block_device {
    volume_size           = 40
    volume_type           = "gp2"
    delete_on_termination = true
  }
  depends_on = [local_file.linux-pem-key]
}
resource "aws_key_pair" "key-pair" {
  key_name   = "${var.linux-keypair}-keypair"
  public_key = tls_private_key.linux-keypair.public_key_openssh
}
resource "tls_private_key" "linux-keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "linux-pem-key" {
  content         = tls_private_key.linux-keypair.private_key_pem
  filename        = "${var.linux-keypair}-keypair.pem"
  file_permission = "0400"
  depends_on      = [tls_private_key.linux-keypair]
}
resource "aws_iam_role" "eks_admin" {
  name = "eks-admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "eks-admin-role"
  }
}