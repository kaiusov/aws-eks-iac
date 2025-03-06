data "aws_availability_zones" "available" {}

# data "aws_security_group" "default" {
#   name   = "default"
#   vpc_id = module.vpc.vpc_id
# }

locals {
  name = "${var.name}-${var.env}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  # version = "3.18.1"
  version = "5.19.0"

  name = "${local.name}-vpc"
  cidr = var.cidr

  azs              = data.aws_availability_zones.available.names
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  # database_subnets = var.database_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  manage_default_security_group  = false
  default_security_group_ingress = []
  default_security_group_egress  = []

  # create_database_subnet_group = true

  tags = {
    Name                                  = local.name
    Environment                           = var.env
    Owner                                 = var.owner
    Terraform                             = "true"
    "kubernetes.io/cluster/${local.name}" = "shared"
  }

  private_subnet_tags = {
    Name                              = "${local.name}-private-subnet"
    Environment                       = var.env
    Owner                             = var.owner
    Terraform                         = "true"
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    Name                     = "${local.name}-public-subnet"
    Environment              = var.env
    Owner                    = var.owner
    Terraform                = "true"
    "kubernetes.io/role/elb" = "1"
  }

  # database_subnet_tags = {
  #   Name        = "${local.name}-database-subnet"
  #   Environment = var.env
  #   Owner       = var.owner
  #   Terraform   = "true"
  # }

  private_route_table_tags = {
    Name        = "${local.name}-private-rt"
    Environment = var.env
    Owner       = var.owner
    Terraform   = "true"
  }

  public_route_table_tags = {
    Name        = "${local.name}-public-rt"
    Environment = var.env
    Owner       = var.owner
    Terraform   = "true"
  }

  # database_route_table_tags = {
  #   Name        = "${local.name}-database-rt"
  #   Environment = var.env
  #   Owner       = var.owner
  #   Terraform   = "true"
  # }
}

# module "endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   # version = "3.18.1"
#   version = "5.19.0"

#   vpc_id = module.vpc.vpc_id

#   endpoints = {
#     s3 = {
#       service         = "s3"
#       service_type    = "Gateway"
#       route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids, module.vpc.database_route_table_ids])
#       tags            = { Name = "s3-vpc-endpoint-${var.env}" }
#     },
#   }

#   tags = {
#     Name        = "${local.name}-s3-endpoint"
#     Environment = var.env
#     Owner       = var.owner
#     Terraform   = "true"
#   }
# }
