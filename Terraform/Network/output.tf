output "my_vpc" {
    value = aws_vpc.my_vpc
}

output "public_subnet_1" {
    value = aws_subnet.public_subnet_1
}

output "public_subnet_2" {
    value = aws_subnet.public_subnet_2
}

output "private_subnet_1" {
    value = aws_subnet.private_subnet_1
}

output "private_subnet_2" {
    value = aws_subnet.private_subnet_2
}
