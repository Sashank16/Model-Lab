pipeline {
    agent any

    environment {
        STAGING_BRANCH = 'staging'
        PRODUCTION_BRANCH = 'master'
        DOCKER_IMAGE_NAME = 'mymavenproject'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/Sashank16/Model-Lab.git'
            }
        }

        stage('Build & Package') {
            steps {
                script {
                    // Use Maven Docker image to build the application
                    docker.image('maven:3.8.4-openjdk-11').inside {
                        // Build the Maven project
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }

        stage('Deploy') {
            parallel {
                stage('Deploy to Staging') {
                    when {
                        branch 'staging' // Deploy only on the staging branch
                    }
                    steps {
                        script {
                            // Build and run the Docker image for staging
                            docker.image('openjdk:11-jre').inside {
                               sh '''
    docker build -t ${DOCKER_IMAGE_NAME}:staging .
    docker run -d --name ${DOCKER_IMAGE_NAME}-staging ${DOCKER_IMAGE_NAME}:staging
'''

                            }
                        }
                    }
                }

                stage('Deploy to Production') {
                    when {
                        branch 'main' // Deploy only on the main branch
                    }
                    steps {
                        script {
                            // Build and run the Docker image for production
                            docker.image('openjdk:11-jre').inside {
                                sh '''
                                docker build -t ${DOCKER_IMAGE_NAME}:production .
                                docker run -d --name ${DOCKER_IMAGE_NAME}-production ${DOCKER_IMAGE_NAME}:production
                                '''
                            }
                        }
                    }
                }
            }
        }

        stage('Automated Testing') {
            steps {
                script {
                    // Run the unit tests
                    sh 'mvn test'
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up containers after the pipeline is complete
                sh '''
                docker stop $(docker ps -q --filter ancestor=${DOCKER_IMAGE_NAME}:staging --filter ancestor=${DOCKER_IMAGE_NAME}:production) || true
                docker rm $(docker ps -a -q --filter ancestor=${DOCKER_IMAGE_NAME}:staging --filter ancestor=${DOCKER_IMAGE_NAME}:production) || true
                '''
            }
        }
        success {
            // Send a notification or other actions on success (optional)
            echo 'Pipeline succeeded!'
        }
        failure {
            // Send a failure notification (optional)
            echo 'Pipeline failed. Check logs.'
        }
    }
}
