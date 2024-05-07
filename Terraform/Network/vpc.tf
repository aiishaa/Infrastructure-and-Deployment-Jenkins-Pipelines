resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
      name = "${var.common_resource_name}-vpc"
    }
}

resource "aws_internet_gateway" "my-IGW" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        name = "${var.common_resource_name}-IGW"
    }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "${var.region}a"
    cidr_block = var.public_subnet_1

    tags = {
        name = "${var.common_resource_name}-public-subnet-1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "${var.region}b"
    cidr_block = var.public_subnet_2

    tags = {
        name = "${var.common_resource_name}-public-subnet-2"
    }
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "${var.region}a"
    cidr_block = var.private_subnet_1

    tags = {
      name = "${var.common_resource_name}-private-subnet-1"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "${var.region}b"
    cidr_block = var.private_subnet_2

    tags = {
      name = "${var.common_resource_name}-private-subnet-2"
    }
}

resource "aws_eip" "EIP_Nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "my-natGW" {
    allocation_id                  = aws_eip.EIP_Nat.id
    subnet_id                      = aws_subnet.public_subnet_1.id
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-IGW.id
    }

    tags = {
        name = "public_route_table"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.my-natGW.id
    }

    tags = {
        name = "private_route_table"
    }
}

resource "aws_route_table_association" "subnet_public_1_route_association" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "subnet_private_1_route_association" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "subnet_public_2_route_association" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "subnet_private_2_route_association" {
    subnet_id = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_route_table.id
}

output "vpc_cidr" {
  value = aws_vpc.my_vpc.cidr_block
}
