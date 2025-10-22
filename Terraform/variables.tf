variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  default     = "aws-key-new"
}

variable "ecr_repo_url" {
  description = "ECR repository URL for Docker image"
  default     = "987686461903.dkr.ecr.ap-south-1.amazonaws.com/docker-image-new:1.0"
}

variable "security_group_name" {
  description = "Security group name for EC2 instance"
  default     = "jenkins-ec2-sg"
}
