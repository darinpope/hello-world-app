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
    DOCKERHUB_CREDS=credentials('dockerhub-darinpope-userpass')
    IMAGE_NAME='darinpope/hello-world-app'
    IMAGE_VERSION='0.0.1'
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
          sh 'buildah build -t $IMAGE_NAME:$IMAGE_VERSION .'
        }
      }
    }
    stage('login to DockerHub') {
      steps {
        container('buildah') {
          sh 'echo $DOCKERHUB_CREDS_PSW | buildah login -u $DOCKERHUB_CREDS_USR --password-stdin docker.io'
        }
      }
    }
    stage('tag image') {
      steps {
        container('buildah') {
          sh 'buildah tag $IMAGE_NAME:$IMAGE_VERSION docker.io/$IMAGE_NAME:$IMAGE_VERSION'
        }
      }
    }
    stage('push image') {
      steps {
        container('buildah') {
          sh 'buildah push docker.io/$IMAGE_NAME:$IMAGE_VERSION'
        }
      }
    }
  }
  post {
    always {
      container('buildah') {
        sh 'buildah logout docker.io'
      }
    }
  }  
}