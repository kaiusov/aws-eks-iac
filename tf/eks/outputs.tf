# Common outputs
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

output "eks_cluster_name" {
  description = "EKS cluster name."
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "eks_oidc_provider_arn" {
  description = "ARN of EKS oidc provider."
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer."
  value       = module.eks.cluster_oidc_issuer_url
}

