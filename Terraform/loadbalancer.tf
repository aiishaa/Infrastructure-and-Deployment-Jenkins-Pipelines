resource "aws_security_group" "elb_sg" {
  name        = "elb-security-group"
  vpc_id      = module.my-vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "elb-security-group"
  }
}

resource "aws_elb" "public-elb" {
  name               = "public-terraform-elb"
  subnets            = [module.my-vpc.public_subnet_1.id, module.my-vpc.public_subnet_2.id] 

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/db"
    interval            = 30
  }

  instances                   = [aws_instance.application_host.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = [aws_security_group.elb_sg.id]

  tags = {
    Name = "public-terraform-elb"
  }
}
