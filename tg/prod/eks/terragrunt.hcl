# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../tf//eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Automatically load environment and account variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_id = local.account_vars.locals.aws_account_id
  user       = local.account_vars.locals.user
  owner      = local.environment_vars.locals.owner
  env        = local.environment_vars.locals.env
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

# These inputs get merged with the common inputs from the root and the envcommon terragrunt.hcl
inputs = {
  vpc_remote_state_key     = "aws/${local.env}/vpc/terraform.tfstate"
  remote_state_bucket      = "${local.owner}-${local.env}-terraform-state"
  whitelisted_ip_addresses = ["0.0.0.0/0"]
  # min_size = 1
  # max_size = 3
  # desired_size = 1
  # node_instance_type = ["t3.nano"]
  # # node_instance_type = "t3.micro"
  eks_map_users = [
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/${local.user}"
      username = "${local.user}"
      groups   = ["system:masters"]
    }
  ]
}