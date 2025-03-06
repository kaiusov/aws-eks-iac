resource "aws_kms_key" "eks_cluster_encryption" {
  description             = "EKS Cluster Encryption (Secrets)"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = {
    Name        = "${local.name}-eks-cluster-kms-key"
    Environment = var.env
    Owner       = var.owner
    Terraform   = "true"
  }
}

locals {
  name                                 = "${var.name}-${var.env}"
  cluster_version                      = "1.32"
  vpc_id                               = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr                             = data.terraform_remote_state.vpc.outputs.vpc_cidr
  partition                            = data.aws_partition.current.partition
  public_subnets                       = data.terraform_remote_state.vpc.outputs.vpc_public_subnets
  private_subnets                      = data.terraform_remote_state.vpc.outputs.vpc_private_subnets
  cluster_endpoint_public_access_cidrs = var.whitelisted_ip_addresses

  eks_map_roles = [
    {
      rolearn  = "arn:${local.partition}:iam::${data.aws_caller_identity.current.account_id}:role/administrator"
      username = "administrator"
      groups   = ["system:masters"]
    }
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name    = local.name
  cluster_version = "1.32"

  cluster_endpoint_private_access          = true
  cluster_endpoint_public_access           = true
  enable_irsa                              = true
  create_cloudwatch_log_group              = true
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  cluster_addons = {
    # coredns = {
    #   resolve_conflicts = "OVERWRITE"
    #   most_recent       = true
    # }
    # kube-proxy = {
    #   resolve_conflicts = "OVERWRITE"
    #   most_recent       = true
    # }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      most_recent       = true
    }
  }

  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = aws_kms_key.eks_cluster_encryption.arn
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnets

  cluster_endpoint_public_access_cidrs = local.cluster_endpoint_public_access_cidrs

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To nodes 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_allow_access_from_controlplane = {
      description                   = "Allow pods to receive communication from the cluster control plane"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
    Name        = local.name
    Environment = var.env
    Owner       = var.owner
    Terraform   = "true"
  }
}

resource "null_resource" "kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
  }
}