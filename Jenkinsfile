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
    IMAGE_TAG='latest'
    IMAGE_ARCH='amd64'
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
          sh 'buildah build -t $IMAGE_NAME:$IMAGE_ARCH --arch $IMAGE_ARCH .'
        }
      }
    }
    stage('tag image') {
      steps {
        container('buildah') {
          sh 'buildah tag $IMAGE_NAME:$IMAGE_ARCH $REGISTRY/$IMAGE_NAME:$IMAGE_ARCH'
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
    stage('push to registry') {
      steps {
        container('buildah') {
          sh 'buildah push $REGISTRY/$IMAGE_NAME:$IMAGE_ARCH'
        }
      }
    }
    stage('create manifest') {
      steps {
        container('buildah') {
          sh 'buildah manifest create $REGISTRY/$IMAGE_NAME:$IMAGE_TAG'
          sh 'buildah manifest add $REGISTRY/$IMAGE_NAME:$IMAGE_TAG docker://$REGISTRY/$IMAGE_NAME:$IMAGE_ARCH'
          sh 'buildah manifest push --all $REGISTRY/$IMAGE_NAME:$IMAGE_TAG docker://$REGISTRY/$IMAGE_NAME:$IMAGE_TAG'
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