output "vpc_id" {
  values = aws_vpc.main.id
}
output "vpc_cidr" {
  values = aws_vpc.main.cidr_block
}
output "public_subnet_ids" {
  values = aws_subnet.public_subnet[*].id
}
output "private_subnet_ids" {
  values = aws_subnet.private_subnets[*].id
}
