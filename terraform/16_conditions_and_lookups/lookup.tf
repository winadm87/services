provider "aws" {
  region = "us-west-1"
}
variable "ec2size" {
  default = {
    "prod" = "t3.large"
	"staging" = "t3.small"
	"dev" = "t3.micro"
  }
}
variable "allow_port_list" {
  default = {
    "prod" = ["443"]
	"dev" = ["80", "443", "22"]
  }
}
variable "env" {
  default = "prod"
} 
resource "aws_instance" "newserv1" {
  ami = paste_here
  instance_type = lookup(var.ec2size,var.env)
  tags = {
    Name = "${var.env} server"
	Owner = "winadm"
  }
}
resource "aws_security_group" "my_webserver" {
  name = "dynamic security group"
  dynamic "ingress" {
    for_each = lookup(var.allow_port_list, var.env) # use lookup from two variables
    content {
	  from_port = ingress.value
	  to_port = ingress.value
	  protocol = "tcp"
	  cidr_blocks = ["0.0.0.0/0"]
	}
  }  
  egress {   # outgoing traffic
    from_port = 0
	to_port = 0
	protocol = "-1"  # any protocol
	cir_blocks = ["0.0.0.0/0"]
  }
}
