data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "tls_private_key" "my_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = tls_private_key.my_key_pair.public_key_openssh
}

resource "local_file" "private_key_pem" {
  filename = "my_key.pem"
  content  = tls_private_key.my_key_pair.private_key_pem
}

resource "null_resource" "copy_file_locally" {
  depends_on = [local_file.private_key_pem]

  provisioner "local-exec" {
    command = "cp my_key.pem key && chmod 600 key"
  }
}

resource "aws_security_group" "bastion_SG" {
    vpc_id = module.my-vpc.my_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      name = "${var.common_resource_name}-publicSG"
    }
}

resource "aws_security_group" "backend_SG" {
    vpc_id = module.my-vpc.my_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }
    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      name = "${var.common_resource_name}-privateSG"
    }
}

resource "aws_instance" "bastion_host" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.ec2_instance_type
    subnet_id =module.my-vpc.public_subnet_1.id
    associate_public_ip_address = true
    security_groups = [aws_security_group.bastion_SG.id]
    key_name = aws_key_pair.my_key.id

    user_data = <<-EOF
      #!/bin/bash
      mkdir -p /home/ec2-user/.ssh
      echo "${tls_private_key.my_key_pair.private_key_pem}" > /home/ec2-user/.ssh/id_rsa
      chmod 400 /home/ec2-user/.ssh/id_rsa
      chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
    EOF

    provisioner "local-exec" {
        command = "echo bastion ansible_host=${self.public_ip} > ../ansible/inventory"
    }

    tags = {
        name = "${var.common_resource_name}-bastion-host"
    }
}

resource "aws_instance" "application_host" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.ec2_instance_type
    subnet_id = module.my-vpc.private_subnet_1.id
    security_groups = [aws_security_group.backend_SG.id]
    key_name = aws_key_pair.my_key.id

    provisioner "local-exec" {
        command = "echo privatehost ansible_host=${self.private_ip} >> ../ansible/inventory"
    }

    tags = {
        name = "${var.common_resource_name}-app-host"
    }
}

output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "private_ec2_private_ip" {
  value = aws_instance.application_host.private_ip
}
