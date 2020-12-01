
## EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "consul" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "m5.large"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.consul.id]
  user_data              = file("${path.module}/scripts/consul.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul.name
  key_name               = var.key_pair

  tags = merge(map("Name", "${var.name_prefix}consul"), var.tags)
}

## IAM
resource "aws_iam_instance_profile" "consul" {
  name = "${var.name_prefix}consul_sd"
  role = aws_iam_role.consul.name
}

resource "aws_iam_role" "consul" {
  name = "${var.name_prefix}f5-consul-role"

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

resource "aws_iam_role_policy" "consul" {
  name = "${var.name_prefix}f5-consul-policy"
  role = aws_iam_role.consul.id

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

## Security Group
resource "aws_security_group" "consul" {
  name   = "${var.name_prefix}consul"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
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

