

pipeline {
    agent any
    options {}
    triggers {}

    stages {
        stage('Clone') {
            checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'GITLAB_CREDS', url: 'http://gitlab:9002/sKallner/bank-leumi-entrance-test.git']])
        }
        stage('Build') {
            sh "docker build -t bank-leumi-entrance-exam-calc:latest ."
        }
        stage('Deploy') {
            sh 'echo "WIP!"'
        }
    }
}