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
    default = "lab2"
}


