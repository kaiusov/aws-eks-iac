data "aws_availability_zones" "available" {}

locals {
  name = "${var.name}-${var.env}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "${local.name}-vpc"
  cidr = var.cidr

  azs              = data.aws_availability_zones.available.names
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  manage_default_security_group  = false
  default_security_group_ingress = []
  default_security_group_egress  = []

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

}