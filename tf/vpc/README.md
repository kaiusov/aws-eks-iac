## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.79 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.79 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.19.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | the AWS region in which resources are created, you must set the availability\_zones variable as well if you define this value to something other than the default | `string` | `""` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | the CIDR block to provision for the VPC | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Project name | `string` | `""` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Stack owner, e.g. "faraway". | `string` | `""` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list(any)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `list(any)` | <pre>[<br/>  ""<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environment"></a> [environment](#output\_environment) | Environment (tier) |
| <a name="output_name"></a> [name](#output\_name) | Project name |
| <a name="output_region"></a> [region](#output\_region) | Target region for all infrastructure resources |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR block of infra VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_database_subnet_group"></a> [vpc\_database\_subnet\_group](#output\_vpc\_database\_subnet\_group) | ID of database subnet group |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of infra VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | Name of infra VPC |
| <a name="output_vpc_private_subnets"></a> [vpc\_private\_subnets](#output\_vpc\_private\_subnets) | Private subnets of infra VPC |
| <a name="output_vpc_private_subnets_cidr"></a> [vpc\_private\_subnets\_cidr](#output\_vpc\_private\_subnets\_cidr) | A list of private subnet CIDR |
| <a name="output_vpc_public_subnets"></a> [vpc\_public\_subnets](#output\_vpc\_public\_subnets) | Public subnets of infra VPC |
| <a name="output_vpc_public_subnets_cidr"></a> [vpc\_public\_subnets\_cidr](#output\_vpc\_public\_subnets\_cidr) | A list of public subnet CIDR |
