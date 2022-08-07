resource "aws_security_group" "app_lb" {
  vpc_id = data.aws_vpc.app.id
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
  }
}

resource "aws_alb" "app" {
  internal        = false
  idle_timeout    = "300"
  security_groups = [
    aws_security_group.app_lb.id
  ]
  subnets = data.aws_subnets.app.ids
}

resource "aws_alb_listener" "app" {
  load_balancer_arn = aws_alb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = aws_acm_certificate.app.arn

  default_action {
    target_group_arn = aws_alb_target_group.app.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group" "app" {
  name     = "app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.app.id
}

resource "aws_alb_listener_rule" "app" {
  listener_arn = aws_alb_listener.app.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  }

  condition {
    host_header {
      values = [local.route]
    }
  }
}
