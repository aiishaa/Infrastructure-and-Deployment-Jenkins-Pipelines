# Jenkins-Task-ITI
## Provision, Configure Infrastructure, Deploy nodejs app in Jenkins Pipeline

#### The project uses two pipelines: one for provisioning and configuring infrastructure, and another for deployment on that infrastructure.

#### 1. Provisioning and Configuring Infrastructure pipeline stages:

#### Before starting you must have these secrets in your jenkins server
Note: Ansible vault contains variables of 

      1. jenkins_server_ip
      2. jenkins_server_port
      3. jenkins_server_secret

![secrets](https://github.com/aiishaa/Jenkins-Task-ITI/assets/57088227/3c827615-4728-4979-8281-8e1f26ae933c)

   
   This pipeline runs on agents with label 'ec2-public-agent' and it consists of two stages:
 
   ## Stage 1: ## 

Running the terraform files that exist inside the Terraform folder on workspace that you pass as a parameter when running the pipeline. 
```bash             
sh "terraform init -upgrade"
sh "terraform workspace select ${environment}"
sh "terraform apply -var-file=${VARS_VALUES} --auto-approve"
```

Assigning the captured output (the public IP address of the bastion host, private IP address for the application instance) to a variable named EC2_PUBLIC_IP and EC2_PRIVATE_IP respectively within the Jenkins pipeline.

```bash
EC2_PUBLIC_IP = sh(script: "terraform output bastion_public_ip", returnStdout: true).trim()
EC2_PRIVATE_IP = sh(script: "terraform output private_ec2_private_ip", returnStdout: true).trim()
```


## Stage 2:
Exceuting an ansible playbook through the bastion host to Configure the private application server to be a slave to the jenkins server 

```bash
dir('ansible') {
    sh 'chmod +x ./ansible_ssh_configuration.sh'
    sh "./ansible_ssh_configuration.sh '${EC2_PUBLIC_IP}' '${EC2_PRIVATE_IP}'"                        
    echo "Waiting for EC2 server to initialize..."
    sleep(time: 60, unit: "SECONDS") 
    withCredentials([file(credentialsId: 'vault-password', variable: 'VAULT_PASSWORD')]) {
        sh "ansible-playbook -i inventory --vault-passwordfile=${VAULT_PASSWORD} --ssh-common-args='-o StrictHostKeyChecking=no' playbook.yml"
    }
}
```

![agents](https://github.com/aiishaa/Jenkins-Task-ITI/assets/57088227/4c7c53d5-4360-490c-84c4-a01899dfd359)


### 2. Depolying nodejs app on the private instance    
   - This pipeline runs on agents with label 'ec2-private-agent', and it consists of stages to build the docker image, push the image to dockerhub and run a container from this image that listens on port 3030.

   - Before starting make sure that environment file taht you pass for docker have the rds, and redis correct endpoints 

   - When you hit the load balancer on path /db you should get 'db connection successful', and on path /redis you should get 'redis is successfully connected' 


![rds-test](https://github.com/aiishaa/Jenkins-Task-ITI/assets/57088227/bcfc8145-9808-4312-bc59-dc1ab3f74569)



![redis-connected](https://github.com/aiishaa/Jenkins-Task-ITI/assets/57088227/8547e5b6-e732-4e0a-8300-793663d831cf)



