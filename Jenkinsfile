pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = 'docker-image-new'
        IMAGE_TAG = "1.0"
        ACCOUNT_ID = '987686461903'          // your AWS account ID
        AWS_CREDS = 'aws-access'            // your Jenkins AWS credential ID
        IMAGE_NAME = "${ECR_REPO}:${IMAGE_TAG}"
        FULL_ECR_NAME = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "🔄 Checking out code from Git..."
                git url: 'https://github.com/sumanvitummala/aws-new.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Tag Docker Image for ECR') {
            steps {
                echo "🏷 Tagging Docker image for ECR..."
                bat "docker tag ${IMAGE_NAME} ${FULL_ECR_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push Docker Image to AWS ECR') {
            steps {
                echo "🚀 Pushing Docker image to AWS ECR..."
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDS}"
                ]]) {
                    bat """
                    aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.%AWS_REGION%.amazonaws.com
                    docker push ${FULL_ECR_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

       
    }
}
