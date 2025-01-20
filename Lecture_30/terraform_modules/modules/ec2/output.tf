output "private_instance_private_ips" {
  value = { for k, inst in aws_instance.private_instance : k => inst.private_ip }
  description = "Mapping of instance keys to private IPs"
}

output "private_instance_public_ips" {
  value = { for k, inst in aws_instance.public_instance : k => inst.public_ip }
  description = "Mapping of instance keys to public IPs"
}
