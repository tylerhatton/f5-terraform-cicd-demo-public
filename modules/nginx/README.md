# Nginx Terraform Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| vpc\_id | ID of VPC to house Consul instance. | `string` | n/a |
| subnet\_id | ID of subnet to house Consul instance. | `string` | n/a |
| key\_pair | Name of AWS key pair used to authenticate into Consul instance. | `string` | `""` |
| name\_prefix | Prefix prepended to names of generated resources. | `string` | n/a |
| tags | Tags applied to generated resources. | `map` | `{}` |
| allow\_from | IP CIDR block of allowed traffic for Consul security groups. | `string` | n/a |
| desired\_capacity | Desired number of Nginx instances in autoscaling group. | `number` | `2` |
| min\_size | Minimum number of Nginx instances in autoscaling group. | `number` | `1` |
| max\_size | Maximum number of Nginx instances in autoscaling group. | `number` | `5` |
| env\_name | Name of environment used for Consul connections. | `string` | n/a |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->