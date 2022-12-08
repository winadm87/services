provider "aws" {
  region = "us-west-2"
}
resource "aws_instance" "my_web_server" {
  ami = "ami-pastehere"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_sebserver.id]
  tags = {
    Name = "WEBSERVER"
  }
  depends_on = [aws_instance.my_db_server, aws_instance.my_app_server] # list of resources that this resource depends on
}
resource "aws_instance" "my_app_server" {
  ami = "ami-pastehere"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_sebserver.id]
  tags = {
    Name = "APPSERVER"
  }
  depends_on = [aws_instance.my_db_server] # list of resources that this resource depends on
}
resource "aws_instance" "my_db_server" {
  ami = "ami-pastehere"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_sebserver.id]
  tags = {
    Name = "DBSERVER"
  }
}
resource "aws_security_group" "my_sebserver" {
  name = "My WEBSERVERs Security Group"
  dynamic "ingress" {
    for_each = ["80", "443"]
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
  tags = {
    Name = "My security group"
  }
}
