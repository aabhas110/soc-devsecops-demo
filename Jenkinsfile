pipeline {

    agent any

    environment {
        IMAGE_NAME = "soc-demo"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code'

                checkout scm

                script {
                    env.COMMIT_SHA = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Git Commit SHA: ${env.COMMIT_SHA}"
                }
            }
        }

        stage('Build') {
            steps {
                echo 'Starting Build Stage'

                sh 'chmod +x build.sh'
                sh './build.sh'
            }
        }

        stage('Test') {
            steps {
                echo 'Starting Test Stage'

                sh 'chmod +x test.sh'
                sh './test.sh'
            }
        }

        stage('Docker Build & Tagging') {
            steps {

                echo 'Building Docker Image'

                sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .

                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest

                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:${COMMIT_SHA}
                """

                echo "Docker Image Tags Created:"
                echo "${IMAGE_NAME}:${BUILD_NUMBER}"
                echo "${IMAGE_NAME}:latest"
                echo "${IMAGE_NAME}:${COMMIT_SHA}"
            }
        }

        stage('Docker Image Verification') {
            steps {

                echo 'Listing Docker Images'

                sh "docker images | grep ${IMAGE_NAME} || true"
            }
        }

        stage('Deploy Dev') {
            steps {

                echo 'Deploying Application to DEV Environment'

                sh 'chmod +x deploy.sh'

                sh "./deploy.sh dev ${BUILD_NUMBER}"
            }
        }

        stage('Health Check') {
            steps {

                echo 'Waiting for container startup'

                sh 'sleep 10'

                echo 'Checking Application Health Endpoint'

                sh 'curl -s http://172.17.0.1:5001/health'
            }
        }
    }

    post {

        success {

            echo 'Pipeline Executed Successfully'

            echo "Stable Build Number: ${BUILD_NUMBER}"

            echo "Stable Commit SHA: ${COMMIT_SHA}"
        }

        failure {

            echo 'Pipeline Failed - Starting Rollback'

            sh 'chmod +x rollback.sh || true'

            sh './rollback.sh || true'
        }

        always {

            echo 'Pipeline Execution Finished'

            sh 'docker ps || true'
        }
    }
}