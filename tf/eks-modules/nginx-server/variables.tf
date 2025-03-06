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

variable "max_history" {
  description = "Helm max history limit"
  type        = string
  default     = "10"
}

variable "nginx_server_chart_version" {
  description = "Version of nginx-Server helm chart"
  type        = string
  default     = "15.7.0"
}

# variable "nginx_server_namespace" {
#   description = "Nginx-Server namespace"
#   type        = string
#   default     = "default"
# }

variable "eks_remote_state_key" {
  description = "EKS remote state key"
  type        = string
  default     = ""
}

variable "remote_state_bucket" {
  description = "Remote state bucket"
  type        = string
  default     = ""
}