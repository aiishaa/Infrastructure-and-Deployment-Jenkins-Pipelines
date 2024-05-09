def buildImage(String imageName) {
    echo "Building the Docker image..."
    sh "docker build -t $imageName ."
}

def dockerLogin() {
    echo "Login to dockerhub..."
    withCredentials([usernamePassword(credentialsId: 'docker-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
        sh "echo $PASS | docker login -u $USER --password-stdin"
    }
}

def dockerPush(String imageName) {
    echo "Pushing the Docker image..."
    sh "docker push $imageName"
}

def dockerRunContainer(String imageName) {
    echo "Starting the Node.js app container..."
    withCredentials([file(credentialsId: 'docker_env_file', variable: 'ENV_FILE')]) {
        sh "docker run --name nodeapp --env-file $ENV_FILE -p 3000:3000 $imageName"
    }
}

return this
