def buildImage(String imageName) {
    withCredentials([file(credentialsId: 'docker_env_file', variable: 'ENV_FILE')]) {
        sh "docker build -t $imageName --env-file $ENV_FILE ."
    }
}

def dockerLogin() {
    echo "Building the Docker image..."
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
    sh "docker run --name nodeapp -p 3000:3000 $imageName"
}

return this
