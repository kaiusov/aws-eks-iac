# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config("${get_parent_terragrunt_dir()}/account.hcl")

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config("${get_parent_terragrunt_dir()}/env.hcl")
  
  # Extract the variables we need for easy access
  account_id = local.account_vars.locals.aws_account_id
  aws_region = local.environment_vars.locals.aws_region
  owner      = local.environment_vars.locals.owner
  env        = local.environment_vars.locals.env
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "aws" {
    region = "${local.aws_region}"

    # Only these AWS Account IDs may be operated on by this template
    allowed_account_ids = ["${local.account_id}"]
  }
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    bucket         = "${local.owner}-${local.env}-terraform-state"
    key            = "aws/${local.env}/${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.aws_region}"
    dynamodb_table = "${local.owner}-${local.env}-terraform-locks"
    encrypt        = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.environment_vars.locals
)
