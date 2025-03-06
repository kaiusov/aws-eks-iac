data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.eks_remote_state_key}"
    region = "${var.aws_region}"
  }
}