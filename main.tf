locals {
  name_prefix = "cicd-demo"
}

data "aws_ssm_parameter" "bigiq_server" {
  name = "/lab-parameters/f5/bigiq_server"
}

data "aws_ssm_parameter" "bigiq_username" {
  name = "/lab-parameters/f5/bigiq_username"
}

data "aws_ssm_parameter" "bigiq_password" {
  name = "/lab-parameters/f5/bigiq_password"
}

data "aws_ssm_parameter" "license_pool" {
  name = "/lab-parameters/f5/license_pool"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.63.0"

  name = "${local.name_prefix}-vpc"
  cidr = "10.128.0.0/16"

  azs             = ["us-west-1a"]
  private_subnets = ["10.128.20.0/24"]
  public_subnets  = ["10.128.10.0/24", "10.128.30.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Lab_ID    = local.name_prefix
  }
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-external-nlb"

  load_balancer_type = "network"

  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.public_subnets[0]]

  target_groups = [
    {
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Terraform = "true"
    Lab_ID    = local.name_prefix
  }
}

resource "aws_lb_target_group_attachment" "external" {
  count = var.bigip_count

  target_group_arn = module.nlb.target_group_arns[0]
  target_id        = module.f5_ltm[count.index].f5_external_private_ips[0]
  port             = 80
}

module "f5_ltm" {
  source = "github.com/tylerhatton/f5-bigip-tf-module"

  count = var.bigip_count

  key_pair    = var.key_pair
  name_prefix = "${local.name_prefix}-${count.index}-"

  vpc_id               = module.vpc.vpc_id
  management_subnet_id = module.vpc.public_subnets[1]
  external_subnet_id   = module.vpc.public_subnets[0]
  internal_subnet_id   = module.vpc.private_subnets[0]

  external_ips      = ["10.128.10.10${count.index}"]
  internal_ips      = ["10.128.20.10${count.index}"]
  management_ip     = "10.128.30.10${count.index}"
  include_public_ip = true

  bigiq_server        = data.aws_ssm_parameter.bigiq_server.value
  bigiq_username      = data.aws_ssm_parameter.bigiq_username.value
  bigiq_password      = data.aws_ssm_parameter.bigiq_password.value
  license_pool        = data.aws_ssm_parameter.license_pool.value
  provisioned_modules = ["\"ltm\": \"nominal\""]

  default_tags = {
    Terraform     = "true"
    ansible_group = "terraform_cicd_demo"
  }
}

resource "aws_ssm_parameter" "bigip_admin_password" {
  count = var.bigip_count

  name  = "/infrastructure/credentials/bigip/${module.f5_ltm[count.index].f5_management_ip}/password"
  type  = "SecureString"
  value = module.f5_ltm[count.index].f5_admin_password
}

resource "aws_ssm_parameter" "bigip_vip_address" {
  count = var.bigip_count

  name  = "/infrastructure/credentials/bigip/${module.f5_ltm[count.index].f5_management_ip}/vip_address"
  type  = "String"
  value = module.f5_ltm[count.index].f5_external_private_ips[0]
}

module "consul" {
  source = "./modules/consul"

  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.private_subnets[0]
  key_pair    = var.key_pair
  name_prefix = "${local.name_prefix}-"
  allow_from  = module.vpc.vpc_cidr_block

  tags = {
    Env = "consul"
  }
}

module "nginx" {
  source = "./modules/nginx"

  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnets[0]
  key_pair         = var.key_pair
  name_prefix      = "${local.name_prefix}-"
  allow_from       = module.vpc.vpc_cidr_block
  desired_capacity = var.nginx_count

  env_name = "consul"
}

resource "null_resource" "ansible" {
  triggers = {
    f5_ltm_management_ips = join(",", module.f5_ltm[*].f5_management_ip)
    ansible_playbook_hash = sha256(file("./playbooks/site.yml"))
    as3_declaration_hash  = sha256(file("./playbooks/templates/as3.j2"))
  }

  provisioner "local-exec" {
    command = <<-EOF
    curl -k -u $TOWER_USERNAME:$TOWER_PASSWORD \
      -X POST \
      -H 'Content-Type:application/json' \
      -d '{"extra_vars":"---\nconsul_ip: ${module.consul.private_ip}"}' \
      https://${var.tower_server}/api/v2/job_templates/${var.tower_job_id}/launch/
    EOF

    environment = {
      TOWER_USERNAME = var.tower_username
      TOWER_PASSWORD = var.tower_password
    }
  }
}