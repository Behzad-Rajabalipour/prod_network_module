# Add output variables
output "private_subnets" {
  value = aws_subnet.private_subnet[*]
}

output "private_route_table" {
  value = aws_route_table.private_route_table
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

