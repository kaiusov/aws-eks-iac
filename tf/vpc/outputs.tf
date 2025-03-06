output "name" {
  description = "Project name"
  value       = local.name
}

output "environment" {
  description = "Environment (tier)"
  value       = var.env
}

output "region" {
  description = "Target region for all infrastructure resources"
  value       = var.aws_region
}

output "vpc_name" {
  description = "Name of infra VPC"
  value       = module.vpc.name
}

output "vpc_id" {
  description = "ID of infra VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of infra VPC"
  value       = var.cidr
}

output "vpc_public_subnets" {
  description = "Public subnets of infra VPC"
  value       = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  description = "Private subnets of infra VPC"
  value       = module.vpc.private_subnets
}

output "vpc_public_subnets_cidr" {
  description = "A list of public subnet CIDR"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_private_subnets_cidr" {
  description = "A list of private subnet CIDR"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_database_subnet_group" {
  description = "ID of database subnet group"
  value       = module.vpc.database_subnet_group
}
