provider "aws" {
  region = "us-west-1"
  alias = "USA"
}
provider "aws" {
  region = "eu-east-1"
  alias "GER"
}
data "aws_ami" "usa_latest_ubuntu" {
  provider = aws.USA
  owners = ["paste_here"]
  most_recent = true
  filter {
    name = "name"
	values = ["ubuntu/images/hvm-ssd-ubuntu-bionic-18.04-amd64-server-*"]
  }
}
resource "aws_instance" {
  provider = aws.USA
  ami = data.aws_ami.usa_latest_ubuntu.id
  instance_type = "t3.micro"
  tags = {
    Name = "USA Server"
  }
}
