pipeline {
    agent none
    environment {
        IMAGE_NAME = 'cid2610/aws-express-js-sample'
        IMAGE_TAG = 'v1'
    }

    stages {
        stage('Install Dependencies') {
            agent {
                docker {
                    image 'node:16-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Node version:"
                    node --version

                    echo "NPM version:"
                    npm --version

                    npm ci
                '''
            }
        }

        stage('Unit Test') {
            agent {
                docker {
                    image 'node:16-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm test
                '''
            }
        }

        stage('Dependency Security Scan') {
            agent {
                docker {
                    image 'node:16-alpine'
                    reuseNode true
                }
            }
            steps {
                withCredentials([
                    string(
                        credentialsId: 'snyk-token',
                        variable: 'SNYK_TOKEN'
                    )
                ]) {
                    sh '''
                        npm install -g snyk
                        echo "Running Snyk dependency vulnerability scan..."
                        snyk test --severity-threshold=high
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            agent any
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest \
                        .
                '''
            }
        }

        stage('Push Docker Image') {
            agent any
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        docker login \
                        -u "$DOCKER_USERNAME" \
                        --password-stdin

                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Review the failed stage before publication.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}