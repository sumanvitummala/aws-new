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
        withCredentials([usernamePassword(credentialsId: 'AWS_ACCESS_KEY_ID', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          bat """
          set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
          set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
          "%AWS_CLI%" ecr get-login-password --region %REGION% | docker login --username AWS --password-stdin %ECR_REPO%
          docker tag %IMAGE_NAME%:latest %ECR_REPO%:latest
          docker push %ECR_REPO%:latest
          """
        }
      }
    }

    


    
}
}

