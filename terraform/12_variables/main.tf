provider "aws" {
  region = var.region # use region variable
}
data "aws_ami" "latest_amazon_linux" {  # get latest ami id
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_server.id
  tags = merge(var.common_tags, { Name = "ServerIP" }) # merge common_tags var with one more value
}
resource "aws_instance" "my_server" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type # use instance_type variable
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  monitoring = var.detailed_monitoring # use detailed_monitoring variablw
  tags = merge(var.common_tags, { Name = "Webserver" })
}
resource "aws_security_group" "my_webserver" { # create security group
  name = "dynamic security group"
  dynamic "ingress" {
    for_each = var.allow_ports # use allow_ports variable
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
  tags = merge(var.common_tags, { Name = "Dynamic SecurityGroup" })
}
