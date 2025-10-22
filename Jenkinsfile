pipeline {
    agent any

    environment {
        AWS_REGION    = 'ap-south-1'
        ECR_REPO      = 'docker-image-new'
        ACCOUNT_ID    = '987686461903'
        IMAGE_TAG     = '1.0'
        AWS_CLI       = 'C:\\Program Files\\Amazon\\AWSCLIV2\\aws.exe'
        TERRAFORM     = 'C:\\Terraform\\terraform.exe'

        IMAGE_NAME    = "${ECR_REPO}:${IMAGE_TAG}"
        FULL_ECR_NAME = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                echo '📦 Cloning repository...'
                git branch: 'main', url: 'https://github.com/sumanvitummala/aws-new.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                bat "docker build -t %IMAGE_NAME% ."
            }
        }

        stage('Push to AWS ECR') {
            steps {
                echo '🚀 Pushing image to AWS ECR...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access']]) {
                    bat """
                    "%AWS_CLI%" ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %FULL_ECR_NAME%
                    docker tag %IMAGE_NAME% %FULL_ECR_NAME%:%IMAGE_TAG%
                    docker push %FULL_ECR_NAME%:%IMAGE_TAG%
                    """
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                echo '🏗️ Deploying EC2 instance and running Docker container...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access']]) {
                    dir('terraform') {
                        bat """
                        "%TERRAFORM%" init

                        REM Import IAM Role if it exists
                        "%TERRAFORM%" import aws_iam_role.ec2_role ec2-ecr-access-role || echo "IAM Role exists, skipping..."

                        REM Import Security Group if it exists
                        "%TERRAFORM%" import aws_security_group.web_sg sg-07709199eac5efed7 || echo "Security Group exists, skipping..."

                        REM Import IAM Instance Profile if it exists
                        "%TERRAFORM%" import aws_iam_instance_profile.ec2_profile ec2-instance-profile || echo "Instance Profile exists, skipping..."

                        REM Apply Terraform
                        "%TERRAFORM%" apply -auto-approve
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment complete! EC2 instance is running your Docker app.'
            echo '🌍 Access it using the EC2 Public IP output from Terraform.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
        always {
            cleanWs()
        }
    }
}




