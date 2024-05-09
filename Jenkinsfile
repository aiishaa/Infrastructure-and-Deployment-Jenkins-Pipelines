pipeline {
    agent { label 'ec2-private-agent' }
    stages {
        stage("init"){
            steps {
                script {
                    gv = load 'script.groovy'
                }
            }
        }
        stage('build image') {
            steps {
                script {
                   echo 'building docker image...'
                   gv.buildImage(env.IMAGE_NAME)
                   gv.dockerLogin()
                   gv.dockerPush(env.IMAGE_NAME)
                }
            }
        }
        stage('deploy') {
            steps {
                gv.dockerRunContainer(env.IMAGE_NAME)
            }
        }
    }
}