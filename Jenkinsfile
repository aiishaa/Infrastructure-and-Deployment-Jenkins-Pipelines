pipeline {
    agent any
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
                            sh "terraform apply --auto-approve"
                            EC2_PUBLIC_IP = sh (
                                script: "terraform output ec2_public_ip",
                                returnStdout: true
                            ).trim()
                        }
                    }
                }
            }
        }
    }
}
