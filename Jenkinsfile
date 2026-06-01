pipeline {
    agent any

    environment {
        APP_NAME   = "maven-project"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        REGISTRY   = "localhost:5000"
        KUBECONFIG = "/var/jenkins_home/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build & Test (Maven, multi-modules)') {
            agent {
                docker {
                    image 'maven:3.9-eclipse-temurin-8'
                    args '-v $HOME/.m2:/root/.m2'
                    reuseNode true
                }
            }
            steps { sh 'mvn -B -U clean test' }
        }

        stage('Package') {
            agent {
                docker {
                    image 'maven:3.9-eclipse-temurin-8'
                    args '-v $HOME/.m2:/root/.m2'
                    reuseNode true
                }
            }
            steps { sh 'mvn -B -U clean package -DskipTests' }
        }

        stage('Docker Build') {
            steps {
                sh """
                    docker build -t ${APP_NAME}:${IMAGE_TAG} .
                    docker images | head -n 10
                """
            }
        }

        stage('Push to local registry') {
            steps {
                sh """
                    docker tag ${APP_NAME}:${IMAGE_TAG} ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}
                    docker push ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to k3s') {
            steps {
                sh """
                    kubectl -n demo apply -f k8s/service.yaml -f k8s/ingress.yaml
                    sed 's|__IMAGE__|${REGISTRY}/${APP_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml | kubectl -n demo apply -f -
                    kubectl -n demo rollout status deployment/${APP_NAME} --timeout=180s
                    kubectl -n demo get pods -o wide
                """
            }
        }
    }

    post {
        always {
            junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true
            archiveArtifacts artifacts: '**/target/*.jar,**/target/*.war', fingerprint: true, allowEmptyArchive: true
        }
    }
}
