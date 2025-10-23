variable "region" { default = "ap-south-1" }
variable "instance_type" { default = "t3.micro" }
variable "key_name" { default = "aws-key-new" }
variable "ecr_repo_url" { default = "987686461903.dkr.ecr.ap-south-1.amazonaws.com/docker-image-new:1.0" }
variable "security_group_name" { default = "jenkins-ec2-sg" }

