provider "aws" { 
  region = var.region
}

# ------------------------------
# IAM Role for EC2 to Access ECR
# ------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "ec2-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [assume_role_policy] # Ignore if policy already exists
  }
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------
# Security Group
# ------------------------------
resource "aws_security_group" "web_sg" {
  name        = var.security_group_name
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-ec2-sg"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------
# Latest Amazon Linux 2 AMI
# ------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# ------------------------------
# EC2 Instance
# ------------------------------
resource "aws_instance" "web" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_groups      = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              sleep 10

              REGION=${var.region}
              REPO=${var.ecr_repo_url}

              aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPO
              docker pull $REPO

              if [ $(docker ps -q -f name=docker-image-new) ]; then
                docker stop docker-image-new
                docker rm docker-image-new
              fi

              docker run -d --name docker-image-new -p 80:80 $REPO
              EOF

  tags = {
    Name = "Docker-App-EC2"
  }
}
