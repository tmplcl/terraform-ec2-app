resource "aws_iam_instance_profile" "app" {
  name = "${var.app_name}_${var.environment}_instance_profile"
  role = aws_iam_role.app.name
}

resource "aws_iam_role" "app" {
  inline_policy {
    name   = "cloudwatch_logs"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:CreateLogGroup"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:logs:${var.region}:*:log-group:${local.log_grop}:*"
        }
      ]
    })
  }

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ssm.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        },
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    })
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
