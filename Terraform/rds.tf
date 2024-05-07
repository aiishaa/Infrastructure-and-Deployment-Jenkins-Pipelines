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
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.backend_SG.id]
    }
}

resource "aws_db_instance" "rds-db" {
  allocated_storage = 10
  db_name              = "mydb"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "aisha"
  password             = "12345678"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds-SG.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
}
