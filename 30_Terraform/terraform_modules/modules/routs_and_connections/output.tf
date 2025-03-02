output "sg" {
  value = aws_security_group.my_sg.id
}

output "nat_ip" {
  value = aws_eip.nat_eip.public_ip
}