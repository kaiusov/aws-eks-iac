# data "aws_eks_cluster" "main" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "main" {
#   name = module.eks.cluster_name
# }

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}