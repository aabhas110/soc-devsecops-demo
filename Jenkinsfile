pipeline {

    agent any

    environment {
        IMAGE_NAME = "soc-demo"
    }

    stages {

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

        stage('Docker Build') {
            steps {
                echo 'Building Docker Image'

                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."

                sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy Dev') {
            steps {
                echo 'Deploying Application'

                sh 'chmod +x deploy.sh'
                sh "./deploy.sh dev ${BUILD_NUMBER}"
            }
        }

        stage('Health Check') {
            steps {
                echo 'Checking Application Health'

                sh 'sleep 10'

                sh 'curl http://host.docker.internal:5001/health || true'
            }
        }
    }

    post {

        success {
            echo 'Pipeline Executed Successfully'
        }

        failure {
            echo 'Pipeline Failed - Starting Rollback'

            sh 'chmod +x rollback.sh || true'
            sh './rollback.sh || true'
        }

        always {
            echo 'Pipeline Execution Finished'
        }
    }
}