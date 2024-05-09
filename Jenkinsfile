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
                    ]) 
                    {
                        dir('Terraform') {
                            // sh "terraform destroy -var-file ${environment}_variables.tfvars --auto-approve"
                            sh "terraform init -upgrade"
                            sh "terraform workspace select ${environment}"
                            sh "terraform apply -var-file ${environment}_variables.tfvars --auto-approve"
                            EC2_PUBLIC_IP = sh (
                                script: "terraform output bastion_public_ip",
                                returnStdout: true
                            ).trim()
                            EC2_PRIVATE_IP = sh (
                                script: "terraform output private_ec2_private_ip",
                                returnStdout: true
                            ).trim()
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
                        sh "./ansible_ssh_configuration.sh '${EC2_PUBLIC_IP}' '${EC2_PRIVATE_IP}'"
                        
                        echo "waiting for EC2 server to initialize.........." 
                        sleep(time: 60, unit: "SECONDS") 

                        withCredentials([file(credentialsId: 'vault-password', variable: 'VAULT_PASSWORD')]) {
                            sh "ansible-playbook -i inventory --vault-password-file=${VAULT_PASSWORD} --ssh-common-args='-o StrictHostKeyChecking=no' playbook.yml"
                        }
                    }
                }
            }
        }
    }
}
