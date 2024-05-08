pipeline {
    agent { label 'ec2-public-agent' }
    parameters {
        string(name: 'environment', defaultValue: 'default', description: 'Workspace/environment file to use for deployment')
    }
    stages {
        stage('Provision Infrastructure') {
            steps {
                script {
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: 'aws-credentials',
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]
                    ]) {
                        dir('Terraform') {
                            sh "terraform init"
                            sh "terraform workspace select ${environment}"
                            sh "terraform apply -var-file ${environment}_variables.tfvars --auto-approve"
                        }
                    }
                }
            }
        }
        stage("Execute Ansible") {
            steps {
                script {
                    dir('ansible') {
                        sh 'chmod +x ./ansible_ssh_configuration.sh'
                        sh './ansible_ssh_configuration.sh'
                        withCredentials([string(credentialsId: 'vault-password', variable: 'VAULT_PASSWORD')]) {
                            def extraVars = [ "vault_password": "@${VAULT_PASSWORD}" ]
                            ansiblePlaybook(
                                disableHostKeyChecking: true,
                                installation: 'Ansible',
                                inventory: 'inventory',
                                playbook: 'playbook.yml',
                                extraVars: extravars
                            )
                        }
                    }
                }
            }
        }
    }
}
