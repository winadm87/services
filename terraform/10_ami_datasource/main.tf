provider "aws" {
  region = "us-west-2"
}
data "aws_ami" "ubuntu_latest" {
  owners = ["copy_here"] # get this value from aws website
  most_recent = true # looking for the latest build
  filter = {
    name = "name"
	value = ["copy_here-*"] # get this value from aws website
  }
}
resource "aws_instance" "my_ubuntu_serv" {
  ami = data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
....
}
output "ubuntu_latest_ami_id" {
  value = data.aws_ami.ubuntu_latest.id
}
output "ubuntu_latest_ami_name" {
  value = data.aws_ami.ubuntu_latest.name
}
