output "vpc" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value       = aws_subnet.public
}

output "private_subnet_id" {
  value       = aws_subnet.private
}
