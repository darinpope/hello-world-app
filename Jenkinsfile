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
    APP_NAME='hello-world-environment-stage'
    PROCESS_TYPE='web'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    durabilityHint('PERFORMANCE_OPTIMIZED')
    disableConcurrentBuilds()
  }
  stages {
    stage('Build') {
      steps {
        container('buildah') {
          sh 'buildah build -t $IMAGE_NAME:$IMAGE_TAG .'
        }
      }
    }
    stage('tag image') {
      steps {
        container('buildah') {
          sh 'buildah tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY/$APP_NAME/$PROCESS_TYPE'
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
    stage('push to registry') {
      steps {
        container('buildah') {
          sh 'buildah push $REGISTRY/$APP_NAME/$PROCESS_TYPE'
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