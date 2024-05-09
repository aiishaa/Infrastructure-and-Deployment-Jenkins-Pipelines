pipeline {
    agent { label 'ec2-private-agent' }
    environment {
        IMAGE_NAME = 'aishafathy/nodeapp:latest'
    }
    stages {
        stage("init") {
            steps {
                script {
                    gv = load 'script.groovy'
                }
            }
        }
        stage('build image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    gv.buildImage(env.IMAGE_NAME)
                    gv.dockerLogin()
                    gv.dockerPush(env.IMAGE_NAME)
                }
            }
        }
        stage('deploy') {
            steps {
                script {
                    gv.dockerRunContainer(env.IMAGE_NAME)
                }
            }
        }
    }
}
