locals {
  route = "${var.subdomain}.${var.hosted_zone}"
  log_grop = "/aws/ec2/${var.app_name}"
}
