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

variable "cidr" {
  description = "the CIDR block to provision for the VPC"
  type        = string
  default     = ""
}

variable "name" {
  description = "Project name"
  type        = string
  default     = ""
}

variable "private_subnets" {
  type        = list(any)
  default     = [""]
  description = ""
}

variable "public_subnets" {
  type        = list(any)
  default     = [""]
  description = ""
}