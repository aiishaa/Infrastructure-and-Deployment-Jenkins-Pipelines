def buildImage(String imageName){
    sh "docker build -t $imageName ."
}

def dockerLogin(){
    echo "building the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]){
        sh "echo $PASS | docker login -u $USER --password-stdin"
    }
}

def dockerPush(String imageName){
    echo "pushing the docker image..."
    sh "docker push $imageName"
}
return this
