# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  name                = "faraway"
  cluster_name        = "eks-cluster"
  owner               = "faraway"
  aws_region          = "us-east-1"
  env                 = "prod"
}
