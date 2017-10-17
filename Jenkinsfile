pipeline {
    agent {
        label 'ubuntu'
    }

    tools {
        maven 'Maven 3.3.9'
        jdk 'jdk8'
    }
    stages {
        stage ('Build') {
            steps {
                sh 'mvn clean package' 
            }
        }
    }
}
