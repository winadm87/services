provider "aws" {
  access_key = "abrakadabra"
  secret_key = "abrakadabra"
  region = "us-west2
}

resource "aws_instance" "my_servers" {
  count = 3 #create 3 servers...
  ami = "ami-(paste_here)" # from this amazon image...
  instance_type = "t3.micro" # with this server type
