provider "aws" {
  region = "us-west-2"
}
terraform {  # place where .tfstate will be stored
  backend "s3" {
    bucket = "bucket_name" # paste bucket name here, use one bucket for one project
    key = "dev/network/terraform.tfstate"  # path to file
	region = "us-west-2"
  }
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "env" {
  default = "dev"
}
variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
	"10.0.2.0/24",
  ]
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}
resource "aws_internet_gateway"  "main" {
  vpc_id = aws_vpc.main.id
  tags = "${var.env}-igw"
}
resource "aws_subnet" "public_subnets" {
  count = length(var.pubic_subnets_cidrs) # how much subnets do we need - take from variable
  vpc_id = aws_vpc.main.id # define vpc in which we will create subnets
  cidr_block = element(var.public_subnet_cidrs, count.index) # take cidr blocks from variable
  availability_zone = data.aws_availability_zones.available.names[count.index] # in which availability zones to create
  map_public_ip_on_launch = true # make subnets public
  tags = {
    name = "${var.env}-public-${count.index + 1}" # create tag with number starting from 1
  }  
}
resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}
resource "aws_route_table_association" "public_routes" {
  count = length(aws_subnet.pubic_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
}
output "vpc_id" { # output value so it can be used in another .tf file 
  value = aws_vpc.main.id
}
output "vpc_cidr" { # output value so it can be used in another .tf file
  value = aws_vpc.main.cidr_block
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}
