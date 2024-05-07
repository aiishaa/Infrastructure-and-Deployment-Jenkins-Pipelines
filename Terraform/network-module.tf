module "my-vpc" {
    source = "./Network"
    vpc_cidr = var.vpc_cidr
    public_subnet_1 = var.public_subnet_1
    private_subnet_1 = var.private_subnet_1
    public_subnet_2 = var.public_subnet_2
    private_subnet_2 = var.private_subnet_2
    region = var.region
    common_resource_name = var.common_resource_name
}