pipeline {

    agent any

    environment {
        IMAGE_NAME = "soc-demo"
        TESTS_REQUIRED = "false"
    }

    stages {

        stage('Build') {
            steps {
                sh 'chmod +x build.sh'
                sh './build.sh'
            }
        }

        stage('Test') {
            steps {
                script {
                    if (env.TESTS_REQUIRED == 'true') {
                        sh 'chmod +x test.sh'
                        sh './test.sh'
                    } else {
                        echo 'Tests pending'
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
            }
        }

        stage('Deploy Dev') {
           
            steps {
                sh 'chmod +x deploy.sh'
                sh './deploy.sh dev $BUILD_NUMBER'
            }
        }
    

    post {

        success {
            echo 'Pipeline Passed'
        }

        failure {
            echo 'Pipeline Failed'

            sh 'chmod +x rollback.sh'
            sh './rollback.sh'
        }
    }
}