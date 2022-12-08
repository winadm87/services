resource "aws_instance" "node1" {
  ami = copy_here
  instance_type = copy_here
  ebs_optimized = true
  vpc_security_group_ids = ["copy_here"]
  tags = {
    Name = "UBUNTUSERVER"
  }
}
resource "aws_security_group" "sg1" {
  description = paste_here
  ingress {
  ... paste_here
  }
  egress {
  ... paste_here
  }
}
