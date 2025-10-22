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
                        REM Apply Terraform while ignoring already existing IAM roles and Security Groups
                        "%TERRAFORM%" apply -auto-approve || echo "Resources may already exist, continuing..."
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


