# Build webserver during bootstrap
provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "my_web_server" {
  ami = "ami-copy_here"  # amazon linux AMI
  instance_type = "t3.micro" # instance type
  vpc_security_group_ids = [aws_security_group.my_webserver.id] # attach instance to security group 
  # on the next string we will set some userparameters that will apply on instance creation step
  user_data = templatefile("userdata.tpl", {
    f_name = "win",
	l_name = "adm",
	names = ["vasya","kolya","john"]
	}) # lets use this variables in template file
  tags = {
    Name = "Web server from terraform"
	Owner = "winadm"
  }
}

resource "aws_security_group" "my_webserver" {
  name = "webserver security group"
  description = "my first security group"
  
  ingress {  # incoming traffic 80 port
    from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {  # incoming traffic 443 port
    from_port = 443
	to_port = 443 
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }  
  
  egress {   # outgoing traffic
    from_port = 0
	to_port = 0
	protocol = "-1"  # any protocol
	cir_blocks = ["0.0.0.0/0"]
  }
}
