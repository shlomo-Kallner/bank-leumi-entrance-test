

pipeline {
    agent any
    // options {}
    // triggers {}
    parameters {
        string(name: 'ANSIBLE_INVENTORY', defaultValue: '', description: 'the Hosts Inventory for Ansible')

        // text(name: 'BIOGRAPHY', defaultValue: '', description: 'Enter some information about the person')

        // booleanParam(name: 'TOGGLE', defaultValue: true, description: 'Toggle this value')

        // choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')

        // password(name: 'PASSWORD', defaultValue: 'SECRET', description: 'Enter a password')
    }

    stages {
        stage('Clone') {
            steps{
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'GITLAB_CREDS', url: 'http://gitlab/sKallner/bank-leumi-entrance-test.git']])
            }
        }
        stage('Build') {
            steps {
                sh "docker build -t bank-leumi-entrance-exam-calc:latest ."
            }
        }
        stage('Deploy') {
            steps {
                withCredentials(
                    [
                        sshUserPrivateKey(credentialsId: 'BankLeumiExamVMSSH', keyFileVariable: 'SSH_KEY_FOR_ANSIBLE')
                        // ,
                        // string(credentialsId: 'Ansible_Inventory', variable: 'ANSIBLE_INVENTORY')
                    ]
                ) {
                    sh """#!/bin/bash
                        python3 -m venv ./.venv
                        . ./.venv/bin/activate
                        python3 -m pip install -U ansible
                        ansible-playbook --syntax-check ./deployment/ansible/playbook.yaml
                        cat ./deployment/ansible/templates/inventory.yaml.dist | sed -e "s/==HOST==/${ANSIBLE_INVENTORY}/g" > ./inventory.yaml
                        # cat ./deployment/ansible/templates/extra-vars.json.dist | sed -e "s/==CIDR==/${NETWORK_CIDR}/g" > ./extra-vars.json
                        ansible-playbook --inventory ./inventory.yaml --private-key ${SSH_KEY_FOR_ANSIBLE} -u "user" -e @./deployment/ansible/templates/extra-vars.json ./deployment/ansible/playbook.yaml
                        # protect our secrets!
                        rm -f ./inventory.yaml
                        rm -f ./extra-vars.json
                    """
                }
            }
        }
    }
}