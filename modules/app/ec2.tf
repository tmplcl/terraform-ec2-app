data "aws_subnets" "app" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_vpc" "app" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 1

  vpc_zone_identifier = data.aws_subnets.app.ids

  target_group_arns = [aws_alb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}

data "aws_ami" "app" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*-hvm-*-arm64-gp2"]
  }
}

resource "aws_launch_template" "app" {
  image_id      = data.aws_ami.app.id
  instance_type = var.instance_type

  name_prefix = var.app_name

  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }
  instance_market_options {
    market_type = "spot"
  }

  vpc_security_group_ids = [aws_security_group.app_instances.id]

  user_data = base64encode(templatefile("${path.module}/start.tftpl",
    {
      app = var.app_name
    }))
}

resource "aws_security_group" "app_instances" {
  vpc_id = data.aws_vpc.app.id
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
  }
}
