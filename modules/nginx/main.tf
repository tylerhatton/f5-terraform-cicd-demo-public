data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_autoscaling_group" "nginx" {
  name                 = "${var.name_prefix}nginx-asg"
  launch_configuration = aws_launch_configuration.nginx.name
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size
  vpc_zone_identifier  = [var.subnet_id]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.name_prefix}nginx"
      propagate_at_launch = true
    },
    {
      key                 = "Env"
      value               = var.env_name
      propagate_at_launch = true
    },
  ]

}

resource "aws_launch_configuration" "nginx" {
  name_prefix   = "${var.name_prefix}nginx-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.nginx.id]
  key_name        = var.key_pair
  user_data       = file("${path.module}/scripts/nginx.sh")

  iam_instance_profile = aws_iam_instance_profile.nginx.name

  lifecycle {
    create_before_destroy = true
  }
}

## IAM
resource "aws_iam_instance_profile" "nginx" {
  name = "${var.name_prefix}nginx_sd"
  role = aws_iam_role.nginx.name
}

resource "aws_iam_role" "nginx" {
  name = "${var.name_prefix}f5-nginx-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "nginx" {
  name = "${var.name_prefix}f5-nginx-policy"
  role = aws_iam_role.nginx.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_security_group" "nginx" {
  name   = "${var.name_prefix}nginx"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}