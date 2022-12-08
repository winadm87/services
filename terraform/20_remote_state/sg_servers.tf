provider "aws" {
  region = "us-west-2"
}
data "terraform_remote_state" "network" { # add data from another .tfstate
  backend = "s3"
  config = {
    bucket = "bucket_name" # paste bucket name here, use one bucket for one project
    key = "dev/network/terraform.tfstate"  # path to file
	region = "us-west-2"    
  }
}
data "aws_ami" "latest_amazon_linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
	values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
terraform {  # place remotestate where .tfstate will be stored
  backend "s3" {
    bucket = "bucket_name" # paste bucket name here, use one bucket for one project
    key = "dev/servers/terraform.tfstate"  # path to file
	region = "us-west-2"
  }
}
variable "" {

}
resource "aws_instance" "web_server" {
  ami = data.aws_ami.latest_amazon_linux
  instance_type = "t2.micro"
  vpc_security_group_ids = ["aws_security_group.webserver.id"]
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data = ....
  tags = {
    Name = "webserver"
	Owner = "winadm"
  }
}
resource "aws_security_group" "webserver" {
  name = "webserver sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id # use output from another .tfstate
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = data.terraform_remote_state.network.outputs.vpc_cidr
  }
  egress {
    from_port = 0
	to_port = 0
	protocol = "-1"  #any protocol
	cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "webserver-sg"
	Owner = "winadm"
  }
}
output "webserver_sg_id" {
  value = aws_security_group.webserver.id
}
output "webserver_public_ip" {
  value = aws_instance.web_server.public_ip
}
