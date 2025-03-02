output "private_ip" {
  value = module.ec2.private_instance_private_ips
}
output "public_ip" {
  value = module.ec2.private_instance_public_ips
}
output "nat_ip" {
  value = module.routs_and_connections.nat_ip
}