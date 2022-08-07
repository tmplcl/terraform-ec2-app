output "route" {
  value = "https://${local.route}"
}

output "asg" {
  value = aws_autoscaling_group.app.arn
}

output "ami" {
  value = aws_launch_template.app.image_id
}

output "alb" {
  value = aws_alb.app.arn
}
