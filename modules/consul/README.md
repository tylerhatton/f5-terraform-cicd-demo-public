# Consul Terraform Module

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

## Outputs

| Name | Description |
|------|-------------|
| private\_ip | Private IPs of Consul instance. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->