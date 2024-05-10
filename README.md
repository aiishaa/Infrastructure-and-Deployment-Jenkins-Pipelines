# Jenkins-Task-ITI
## Provision, Configure Infrastructure, Deploy nodejs app in Jenkins Pipeline

#### The project uses two pipelines: one for provisioning and configuring infrastructure, and another for deployment on that infrastructure.

#### 1. Provisioning and Configuring Infrastructure pipeline stages:
   #### This pipeline runs on agents with label 'ec2-public-agent' and it consists of two stages:
 
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
