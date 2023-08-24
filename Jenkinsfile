pipeline {
    agent { dockerfile true }
    stages {
        stage('Test') {
            steps {
                sh 'gcc --version'
                sh 'git --version'
                sh 'apt list --installed | grep libpcap'
            }
        }
    }
}