pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = 'docker-image-new'
        IMAGE_TAG = "1.0"
        ACCOUNT_ID = '987686461903'          // your AWS account ID
        AWS_CREDS = 'aws-access'            // your Jenkins AWS credential ID
        IMAGE_NAME = "${ECR_REPO}:${IMAGE_TAG}"
        FULL_ECR_NAME = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
        PEM_PATH = "D:/aws-key-new.pem"      // path to your .pem private key
        EC2_USER = "ec2-user"
        EC2_HOST = ""                        // will be populated with Terraform output
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
                bat "docker tag ${IMAGE_NAME} ${FULL_ECR_NAME}"
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
                    docker push ${FULL_ECR_NAME}
                    """
                }
            }
        }

        stage('Deploy on EC2') {
    steps {
        script {
            def ec2_ip = bat(script: 'terraform output -raw ec2_public_ip', returnStdout: true).trim()
            echo "🚢 Deploying Docker container on EC2: ${ec2_ip}"

            // Replace backslashes in PEM path for SSH
            def pemPath = PEM_PATH.replaceAll('\\\\', '/')

            bat """
            echo y | plink -i ${pemPath} ec2-user@${ec2_ip} "docker stop docker-image-new || true"
            echo y | plink -i ${pemPath} ec2-user@${ec2_ip} "docker rm docker-image-new || true"
            echo y | plink -i ${pemPath} ec2-user@${ec2_ip} "docker run -d -p 80:80 --name docker-image-new ${FULL_ECR_NAME}"
            """
        }
    }
}


    post {
        success {
            echo "✅ Pipeline completed successfully!"
            // Optionally, add email or Slack notification here
        }
        failure {
            echo "❌ Pipeline failed. Please check the logs!"
            // Optionally, add email or Slack notification here
        }
        always {
            echo "🔄 Cleaning up workspace..."
            cleanWs()  // Cleans up Jenkins workspace
        }
    }
}
}

