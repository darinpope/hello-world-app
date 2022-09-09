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
    REGISTRY='docker.io'
    IMAGE_NAME='darinpope/hello-world-app'
    IMAGE_TAG='0.0.1'
    MANIFEST_NAME='hello-world-app'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    durabilityHint('PERFORMANCE_OPTIMIZED')
    disableConcurrentBuilds()
  }
  stages {
    stage('create manifest') {
      steps {
        container('buildah') {
          sh 'buildah manifest create $MANIFEST_NAME'
        }
      }
    }
    stage('Build') {
      steps {
        container('buildah') {
          sh 'buildah build -t $REGISTRY/$IMAGE_NAME:$IMAGE_TAG --manifest $MANIFEST_NAME .'
        }
      }
    }
    stage('login to DockerHub') {
      steps {
        container('buildah') {
          sh 'echo $DOCKERHUB_CREDS_PSW | buildah login -u $DOCKERHUB_CREDS_USR --password-stdin $REGISTRY'
        }
      }
    }
    stage('push manifest') {
      steps {
        container('buildah') {
          sh 'buildah manifest push --all $MANIFEST_NAME docker://$REGISTRY/$IMAGE_NAME:$IMAGE_TAG'
        }
      }
    }
    stage('push image') {
      steps {
        container('buildah') {
          sh 'buildah push $REGISTRY/$IMAGE_NAME:$IMAGE_TAG'
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