provider "aws" {
  region = "us-west-1"
}
module "vpc-default" { # all by default in module variables
  source = "../modules/aws_network"
}
module "vpc-dev" {  # override variables in module
  source = "../modules/aws_network"
  env = "development"
  vpc_cidr = "10.100.0.0/16"
  public_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = [] # this will not create any private subnets and resource that depends on them
}
module "vpc-prod" {  # override variables in module
  source = "../modules/aws_network"
  env = "production"
  vpc_cidr = "10.10.0.0/16"
  public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}
output "prod_public_subnet_ids" {
  value = module.vpc-prod.public_subnet_ids
}
output "prod_private_subnet_ids" {
  value = module.vpc-prod.private_subnet_ids
}
output "dev_public_subnet_ids" {
  value = module.vpc-dev.public_subnet_ids
}
output "dev_private_subnet_ids" {
  value = module.vpc-dev.private_subnet_ids
}
