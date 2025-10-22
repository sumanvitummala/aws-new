pipeline {
    agent any

    environment {
        // AWS & ECR configuration
        AWS_REGION = 'ap-south-1'
        ECR_ACCOUNT_ID = '987686461903'
        ECR_REPO = 'docker-image-new'
        IMAGE_TAG = '1.0'
        IMAGE_NAME = "${ECR_REPO}:${IMAGE_TAG}"
        FULL_ECR_NAME = "987686461903.dkr.ecr.ap-south-1.amazonaws.com/docker-image-new"

        // // Terraform configuration
        // TERRAFORM_DIR = '.'   // terraform.tf is in repo root
    }

    stages {

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Tag Docker Image for ECR') {
            steps {
                echo "🏷 Tagging Docker image for ECR..."
                bat "docker tag ${IMAGE_NAME} ${FULL_ECR_NAME}"
            }
        }

        stage('Push to AWS ECR') {
    steps {
        echo '🚀 Pushing image to AWS ECR...'
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'AWS_ACCESS_KEY_ID' // Replace with your AWS credentials ID
        ]]) {
            bat """
            set AWS_REGION=ap-south-1
            set REPO_URL=987686461903.dkr.ecr.ap-south-1.amazonaws.com
            aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %REPO_URL%
            docker tag docker-image-new:1.0 %REPO_URL%/docker-image-new:latest
            docker push %REPO_URL%/docker-image-new:latest
            """
        }
    }
}

    


    
}
}

