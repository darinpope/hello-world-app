pipeline {
  agent any
  stages {
    stage('do source files have a license?') {
      steps {
        sh 'addlicense -check $(find -type f -name *.java)'
      }
    }
  }
}
