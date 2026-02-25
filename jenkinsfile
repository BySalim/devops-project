pipeline {
  agent any

  environment {
    APP_NAME   = "maven-project"
    IMAGE_TAG  = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Test (Maven, multi-modules)') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-8'
          args  '-v $HOME/.m2:/root/.m2'
        }
      }
      steps {
        sh 'mvn -B -U clean test'
      }
    }

    stage('Package') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-8'
          args  '-v $HOME/.m2:/root/.m2'
        }
      }
      steps {
        sh 'mvn -B -U clean package -DskipTests'
      }
    }

    stage('Show outputs') {
      steps {
        sh '''
          echo "=== server target ==="
          ls -lah server/target || true
          echo "=== webapp target ==="
          ls -lah webapp/target || true
        '''
      }
    }

    stage('Docker Build') {
      steps {
        sh """
          docker build -t ${APP_NAME}:${IMAGE_TAG} .
          docker images | head -n 10
        """
      }
    }
  }

  post {
    always {
      junit '**/target/surefire-reports/*.xml'
      archiveArtifacts artifacts: '**/target/*.jar, **/target/*.war', fingerprint: true, allowEmptyArchive: true
    }
  }
}