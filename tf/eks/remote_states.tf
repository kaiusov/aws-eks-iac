data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.vpc_remote_state_key}"
    region = "${var.aws_region}"
  }
}