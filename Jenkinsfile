pipeline {
    agent {
        label 'ubuntu'
    }

    tools {
        maven 'Maven 3.3.9'
        jdk 'JDK 1.8 (latest)'
    }
    stages {
        stage ('Build') {
            steps {
                sh 'mvn clean package' 
            }
        }

        // based on https://cwiki.apache.org/confluence/display/INFRA/Multibranch+Pipeline+recipies
        stage ('Deploy site') {
            when {
                branch 'master'
            }

            agent {
                node {
                    label 'git-websites'
                }
            }

            steps {
                sh 'mvn clean package -Ppublish-site -Dmsg="Automatic website deployment"'
            }
        }
    }
}
