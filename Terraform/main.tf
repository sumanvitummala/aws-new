provider "aws" {
  region = "ap-south-1"
}

# Key pair for EC2 (use your existing .pem private key)
# Generate the public key from your PEM first:
# ssh-keygen -y -f D:/aws-key-new.pem > D:/aws-key-new.pub
resource "aws_key_pair" "jenkins_ec2_key" {
  key_name   = "jenkins-ec2-key"
  public_key = file("D:/aws-key-new.pub")
}

# Security group to allow SSH and HTTP
resource "aws_security_group" "jenkins_ec2_sg" {
  name        = "jenkins-ec2-sg"
  description = "Allow SSH and HTTP"

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
}

# EC2 instance
resource "aws_instance" "jenkins_ec2" {
  ami           = "ami-06fa3f12191aa3337"  # Your AMI ID
  instance_type = "t3.micro"               # Your instance type
  key_name      = aws_key_pair.jenkins_ec2_key.key_name
  security_groups = [aws_security_group.jenkins_ec2_sg.name]

  tags = {
    Name = "Jenkins-Docker-EC2"
  }

  # Install Docker on EC2 after launch
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("D:/aws-key-new.pem")
    }
  }
}

# Output the public IP of EC2

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
