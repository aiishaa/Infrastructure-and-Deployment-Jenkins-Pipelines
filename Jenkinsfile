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
                            //sh "terraform destroy -var-file ${environment}_variables.tfvars --auto-approve"
                            sh "terraform init"
                            sh 'terraform workspace select ${environment}'
                            sh "terraform apply -var-file ${environment}_variables.tfvars --auto-approve"
                            // EC2_PUBLIC_IP = sh (
                                // script: "terraform output ec2_public_ip",
                                // returnStdout: true
                            // ).trim()
                        }
                    }
                }
            }
        }
        stage("Execute Ansible") {
            steps {
                script {
                    dir('ansible') {
                        sh './ansible_ssh_configuration.sh'
                        withCredentials([string(credentialsId: 'vault-password', variable: 'VAULT_PASSWORD')]) {
                            ansiblePlaybook(
                                disableHostKeyChecking: true,
                                installation: 'Ansible',
                                inventory: 'inventory',
                                playbook: 'playbook.yml',
                                extraVars: [vault_password: ${VAULT_PASSWORD}]
                            )
                        }
                    }
                }
            }
        }
    }
}
