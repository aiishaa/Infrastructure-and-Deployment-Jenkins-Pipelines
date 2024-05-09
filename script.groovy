def buildImage(String imageName){
    sh "docker build -t $imageName ."
}

def dockerLogin(){
    echo "building the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]){
        sh "echo $PASS | docker login -u $USER --password-stdin"
    }
}

def dockerPush(String imageName){
    echo "pushing the docker image..."
    sh "docker push $imageName"
}

def dockerRunContainer(String imageName){
    echo "Starting the nodejs app container..."
    sh "docker run --name nodeapp -p 3000:3000 $imageName"
}
return this
