variable "key_pair" {}

variable "bigip_count" {
  default     = 2
  description = "Number of F5 BIG-IPs in cluster to provision"
}

variable "nginx_count" {
  default     = 3
  description = "Number of Nginx nodes in cluster to provision"
}

variable "tower_server" {
  description = "Hostname or IP address of Ansible Tower server Ansible Playbook will be executed on."
}

variable "tower_username" {
  description = "Username to authenticate into Ansible Tower server."
}

variable "tower_password" {
  description = "Password to authenticate into Ansible Tower server."
}

variable "tower_job_id" {
  description = "Ansible Tower job ID for the Ansible Tower job to be executed as part of the Terraform job."
}
