pipeline {

    agent any

    parameters {
        string(name: 'APP_NAME', defaultValue: 'soc-demo', description: 'Application / Docker image name')
        string(name: 'APP_PORT', defaultValue: '5001', description: 'Host port for application')
        string(name: 'CONTAINER_PORT', defaultValue: '5000', description: 'Container port exposed by app')
        string(name: 'HEALTH_ENDPOINT', defaultValue: '/health', description: 'Application health endpoint')
        string(name: 'DEPLOY_ENV', defaultValue: 'dev', description: 'Deployment environment')
    }

    environment {
        IMAGE_NAME = "${params.APP_NAME}"
        CONTAINER_NAME = "${params.APP_NAME}-${params.DEPLOY_ENV}"
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

                script {
                    if (fileExists('build.sh')) {
                        sh 'chmod +x build.sh'
                        sh './build.sh'
                    } else {
                        echo 'build.sh not found, skipping build stage'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Starting Test Stage'

                script {
                    if (fileExists('test.sh')) {
                        sh 'chmod +x test.sh'
                        sh './test.sh'
                    } else {
                        echo 'test.sh not found, skipping test stage'
                    }
                }
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

        stage('Deploy') {
            steps {
                echo "Deploying ${IMAGE_NAME} to ${params.DEPLOY_ENV}"

                script {
                    if (fileExists('deploy.sh')) {
                        sh 'chmod +x deploy.sh'
                        sh "./deploy.sh ${params.DEPLOY_ENV} ${BUILD_NUMBER}"
                    } else {
                        echo 'deploy.sh not found, using default Docker deployment'

                        sh """
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true

                            docker run -d \
                                --name ${CONTAINER_NAME} \
                                -p ${params.APP_PORT}:${params.CONTAINER_PORT} \
                                --restart unless-stopped \
                                ${IMAGE_NAME}:${BUILD_NUMBER}
                        """
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo 'Waiting for container startup'
                sh 'sleep 10'

                echo 'Checking Application Health Endpoint'

                sh """
                    curl -f http://172.17.0.1:${params.APP_PORT}${params.HEALTH_ENDPOINT}
                """
            }
        }
    }

    post {

        success {
            echo 'Pipeline Executed Successfully'
            echo "Application Name: ${IMAGE_NAME}"
            echo "Environment: ${params.DEPLOY_ENV}"
            echo "Stable Build Number: ${BUILD_NUMBER}"
            echo "Stable Commit SHA: ${COMMIT_SHA}"
        }

        failure {
            echo 'Pipeline Failed - Starting Rollback'

            script {
                if (fileExists('rollback.sh')) {
                    sh 'chmod +x rollback.sh || true'
                    sh './rollback.sh || true'
                } else {
                    echo 'rollback.sh not found, skipping rollback'
                }
            }
        }

        always {
            echo 'Pipeline Execution Finished'
            sh 'docker ps || true'
            sh "docker images | grep ${IMAGE_NAME} || true"
        }
    }
}