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
        RESTORE_DIR = "/var/jenkins_home/restore-points"
        AIOPS_DIR = "/var/jenkins_home/aiops-reports"
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

                sh '''
                    if [ -f build.sh ]; then
                        chmod +x build.sh
                        ./build.sh
                    else
                        echo "build.sh not found, skipping build stage"
                    fi
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Starting Test Stage'

                sh '''
                    if [ -f test.sh ]; then
                        chmod +x test.sh
                        ./test.sh
                    else
                        echo "test.sh not found, skipping test stage"
                    fi
                '''
            }
        }

        stage('Docker Build & Tagging') {
            steps {
                echo 'Building Docker Image'

                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:${COMMIT_SHA}
                '''

                echo "Docker Image Tags Created:"
                echo "${IMAGE_NAME}:${BUILD_NUMBER}"
                echo "${IMAGE_NAME}:latest"
                echo "${IMAGE_NAME}:${COMMIT_SHA}"
            }
        }

        stage('Docker Image Verification') {
            steps {
                echo 'Listing Docker Images'
                sh '''
                    docker images | grep ${IMAGE_NAME} || true
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying ${IMAGE_NAME} to ${params.DEPLOY_ENV}"

                sh '''
                    chmod +x deploy.sh

                    APP_NAME=${IMAGE_NAME} \
                    APP_PORT=${APP_PORT} \
                    CONTAINER_PORT=${CONTAINER_PORT} \
                    ./deploy.sh ${DEPLOY_ENV} ${BUILD_NUMBER}
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo 'Waiting for container startup'
                sh 'sleep 10'

                echo 'Checking Application Health Endpoint'

                sh '''
                    curl -f http://172.17.0.1:${APP_PORT}${HEALTH_ENDPOINT}
                '''
            }
        }

        stage('Save Restore Point') {
            steps {
                echo 'Saving restore point for last successful deployment'

                sh '''
                    mkdir -p ${RESTORE_DIR}

                    cat > ${RESTORE_DIR}/${IMAGE_NAME}-last-successful.env <<EOF
APP_NAME=${IMAGE_NAME}
BUILD_NUMBER=${BUILD_NUMBER}
COMMIT_SHA=${COMMIT_SHA}
IMAGE_TAG=${IMAGE_NAME}:${BUILD_NUMBER}
CONTAINER_NAME=${CONTAINER_NAME}
APP_PORT=${APP_PORT}
CONTAINER_PORT=${CONTAINER_PORT}
HEALTH_ENDPOINT=${HEALTH_ENDPOINT}
DEPLOY_ENV=${DEPLOY_ENV}
EOF

                    echo "Restore point saved:"
                    cat ${RESTORE_DIR}/${IMAGE_NAME}-last-successful.env
                '''

                archiveArtifacts artifacts: '**/*last-successful.env', allowEmptyArchive: true, fingerprint: true
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
            echo 'Pipeline Failed - Starting AIOps Log Collection'

            sh '''
                mkdir -p ${AIOPS_DIR}/${IMAGE_NAME}-${BUILD_NUMBER}

                docker ps -a > ${AIOPS_DIR}/${IMAGE_NAME}-${BUILD_NUMBER}/docker-ps.txt || true
                docker images | grep ${IMAGE_NAME} > ${AIOPS_DIR}/${IMAGE_NAME}-${BUILD_NUMBER}/docker-images.txt || true
                docker logs ${CONTAINER_NAME} > ${AIOPS_DIR}/${IMAGE_NAME}-${BUILD_NUMBER}/container-logs.txt 2>&1 || true

                echo "AIOps report path:"
                echo "${AIOPS_DIR}/${IMAGE_NAME}-${BUILD_NUMBER}"
            '''

            archiveArtifacts artifacts: '**/aiops-reports/**/*', allowEmptyArchive: true

            echo 'Starting Restore Point Rollback'

            sh '''
                if [ -f rollback.sh ]; then
                    chmod +x rollback.sh
                    APP_NAME=${IMAGE_NAME} ./rollback.sh || true
                else
                    echo "rollback.sh not found, rollback skipped"
                fi
            '''
        }

        always {
            echo 'Pipeline Execution Finished'

            sh '''
                docker ps || true
                docker images | grep ${IMAGE_NAME} || true
            '''
        }
    }
}
