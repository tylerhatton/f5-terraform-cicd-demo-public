output "private_ip" {
  value       = aws_instance.consul.private_ip
  description = "Private IPs of Consul instance."
}
