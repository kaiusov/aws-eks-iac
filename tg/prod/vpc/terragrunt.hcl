# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `root.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

# locals {
#   account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
#   environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
# }

terraform {
  source = "../../../tf//vpc"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
# locals {
#   # Automatically load environment-level variables
#   # global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
#   environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

#   # Extract out common variables for reuse
#   # env = local.environment_vars.locals.env
# }

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

# These inputs get merged with the common inputs from the root and the envcommon terragrunt.hcl
inputs = {
  private_subnets     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public_subnets      = ["10.0.100.0/22", "10.0.104.0/22", "10.0.108.0/22"]
  # database_subnets    = ["10.0.112.0/22", "10.0.116.0/22", "10.0.120.0/22"]
  cidr                = "10.0.0.0/16"
}
