variable "owner" {
  description = "Stack owner, e.g. \"faraway\"."
  type        = string
  default     = ""
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  type        = string
  default     = ""
}

variable "name" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "whitelisted_ip_addresses" {
  description = "IP Addresses allowed to K8S control plane access"
  type        = list(string)
  default     = [""]
}

variable "eks_map_users" {
  description = "EKS users for access to cluster"
  type        = list(any)
  default     = [""]
}


variable "vpc_remote_state_key" {
  description = "VPC remote state key"
  type        = string
  default     = ""
}

variable "remote_state_bucket" {
  description = "Remote state bucket"
  type        = string
  default     = ""
}

# variable "node_instance_type" {
#   description = "Instance type of the EKS Node Group"
#   type        = list(string)
#   # type    = string
# }

# variable "min_size" {
#   description = "Minimum number of nodes in the clustenr node group"
#   type        = number
# }

# variable "desired_size" {
#   description = "Desired number of nodes in the clustenr node group"
#   type        = number
# }

# variable "max_size" {
#   description = "Maxiumum number of nodes in the clustenr node group"
#   type        = number
# }