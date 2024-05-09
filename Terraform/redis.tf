resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "my-redis-cache-subnet"
  subnet_ids = [module.my-vpc.private_subnet_1.id, module.my-vpc.private_subnet_2.id]
  tags = {
    Name = "My  redis Subnet Group"
  }
}

resource "aws_security_group" "redis-SG" {
    vpc_id = module.my-vpc.my_vpc.id
    ingress {
        from_port   = var.redis_cluster['cluster_port']
        to_port     = var.redis_cluster['cluster_port']
        protocol    = "tcp"
        security_groups = [aws_security_group.rds-SG.id]
    }
}
resource "aws_elasticache_cluster" "elasticache-redis" {
  cluster_id           = var.redis_cluster['cluster_id']
  engine               = var.redis_cluster['cluster_engine']
  node_type            = var.redis_cluster['cluster_nodetype']
  num_cache_nodes      = var.redis_cluster['cluster_nOfnodes']
  parameter_group_name = "default.redis7"
  port                 = var.redis_cluster['cluster_port']
  security_group_ids = [aws_security_group.redis-SG.id]
  subnet_group_name = aws_elasticache_subnet_group.redis_subnet_group.name
}
