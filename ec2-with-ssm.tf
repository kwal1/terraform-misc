provider "aws" {
    region = "us-west-2"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
    name = "ssm_instance_profile"
    role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
    name = "ssm_role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
    role       = aws_iam_role.ssm_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2_instance" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t3.micro"
    iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name

    tags = {
        Name = "EC2 Instance"
    }
}
