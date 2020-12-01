output "bigip_management_ips" {
  value       = module.f5_ltm[*].f5_management_ip
  description = "List of management public IPs to access provisioned F5 appliances."
}

output "nlb_dns_name" {
  value       = module.nlb.this_lb_dns_name
  description = "DNS name for tier one load balancer that targets the F5 demo VIP."
}