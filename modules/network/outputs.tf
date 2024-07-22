output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "network_interface_id" {
  value = aws_network_interface.public.id
}

output "security_group_id" {
  value = aws_security_group.cluster.id
}



# output "aws_network_interface" {
#   value = aws_network_interface.public.id
# }

# output "network_interface_ids" {
#   value = aws_network_interface.public[*].id
# }