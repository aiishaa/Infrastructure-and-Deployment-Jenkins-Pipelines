resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "db-subnet-group"

  subnet_ids = [module.my-vpc.private_subnet_1.id, module.my-vpc.private_subnet_2.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "aws_security_group" "rds-SG" {
    vpc_id = module.my-vpc.my_vpc.id
    ingress {
        from_port   = var.database_server['db_port']
        to_port     = var.database_server['db_port']
        protocol    = "tcp"
        security_groups = [aws_security_group.backend_SG.id]
    }
}

resource "aws_db_instance" "rds-db" {
  allocated_storage    = var.database_server['db_allocated_storage']
  db_name              = var.database_server['db_name']
  engine               = var.database_server['db_engine']
  instance_class       = var.database_server['db_instance_class']
  username             = var.database_server['db_username']
  password             = var.database_server['db_password']
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds-SG.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
}
