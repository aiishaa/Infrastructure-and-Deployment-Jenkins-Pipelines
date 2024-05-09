variable vpc_cidr {
    type = string
    description = "vpc cidr block"
}

variable env {
    type = string
    description = "workspace environment"
}

variable public_subnet_1 {
    type = string
}

variable public_subnet_2 {
    type = string
}

variable private_subnet_1 {
    type = string
}

variable private_subnet_2 {
    type = string
}

variable ec2_instance_type {
    type = string
}

variable region {
    type = string
}

variable common_resource_name {
    type = string
    default = "project"
}

variable "database_server" {
  type = object({
        db_password = string
        db_username = string
        db_name = string
        db_engine = string
        db_instance_class = string
        db_allocated_storage = number
        db_port = number
  })
}

variable "redis_cluster" {
    type = object({
        cluster_id      = string
        cluster_engine  = string
        cluster_nodetype = string
        cluster_nOfnodes = number
        cluster_port    = number
})
}
