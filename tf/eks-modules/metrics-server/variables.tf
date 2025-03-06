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

variable "metrics_server_chart_version" {
  description = "Version of Metrics-Server helm chart"
  type        = string
  default     = "3.11.0"
}

# variable "metrics_server_namespace" {
#   description = "Metrics-Server namespace"
#   type        = string
#   default     = "observability"
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