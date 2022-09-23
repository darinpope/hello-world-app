pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  name: buildah
spec:
  containers:
  - name: maven
    image: maven:3.8.6-eclipse-temurin-17
    command:
    - cat
    tty: true
  - name: buildah
    image: quay.io/buildah/stable:v1.27.0
    command:
    - cat
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
      - name: varlibcontainers
        mountPath: /var/lib/containers
  volumes:
    - name: varlibcontainers
'''   
    }
  }
  environment {
    HEROKU_API_KEY = credentials('heroku-api-key')
    REGISTRY='registry.heroku.com'
    IMAGE_NAME='darinpope/hello-world-app'
    IMAGE_TAG='0.0.1'
    STAGE_APP_NAME='hello-world-environment-stage'
    PROD_APP_NAME='hello-world-environment-prod'
    PROCESS_TYPE='web'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    durabilityHint('PERFORMANCE_OPTIMIZED')
    disableConcurrentBuilds()
  }
  stages {
    stage('Run Tests') {
      steps {
        container('maven') {
          sh '''
            mvn --version
            mvn clean test
          '''
        }
      }
    }
    stage('Build') {
      steps {
        container('buildah') {
          sh 'buildah build -t $IMAGE_NAME:$IMAGE_TAG .'
        }
      }
    }
    stage('tag image for both registries') {
      steps {
        container('buildah') {
          sh 'buildah tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY/$STAGE_APP_NAME/$PROCESS_TYPE'
          sh 'buildah tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY/$PROD_APP_NAME/$PROCESS_TYPE'
        }
      }
    }
    stage('login to Heroku Registry') {
      steps {
        container('buildah') {
          sh 'echo $HEROKU_API_KEY | buildah login --username=_ --password-stdin $REGISTRY'
        }
      }
    }
    stage('push to stage registry') {
      steps {
        container('buildah') {
          sh 'buildah push --format=v2s2 $REGISTRY/$STAGE_APP_NAME/$PROCESS_TYPE'
        }
      }
    }
    stage('push to prod registry') {
      steps {
        container('buildah') {
          sh 'buildah push --format=v2s2 $REGISTRY/$PROD_APP_NAME/$PROCESS_TYPE'
        }
      }
    }
  }
  post {
    always {
      container('buildah') {
        sh 'buildah logout $REGISTRY'
      }
    }
  }  
}