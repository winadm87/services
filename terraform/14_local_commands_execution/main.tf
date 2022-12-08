provider "aws" {
  region = "us-west-2"
}
resource "null_resource" "command1" { # null resource
  provisioner "local-exec" { # run local command on terraform server
    command = "echo Terraform good puppet > log.log" # command itself
  }
}
resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "df -al /var/log"
  }
  depends_on = [null.resource.command1] # define dependancy on command1
}
resource "null_resource" "command3" {
  provisioner "local-exec" {
    command = "print('HelloWorld')" # define command
	interpreter = ["python", "-c"]  # define interpreter
  }
}
resource "null_resource" "command4" {
  provisioner "local-exec" {
    command = "echo $NAME1 $NAME2 > names.txt"
	environment {
	  NAME1 = "alko"
	  NAME2 = "boom"
	}
  }
}
resource "null_resource" "command5" { 
  provisioner "local-exec" { 
    command = "echo Terraform good puppet > log.log" 
  }
  depends_on = [null_resource.command1,null_resource.command2,null_resource.command3]
}
resource "aws_instance" "my_server" {
  ami = copy-here
  instance_type = "t3.micro"
  provisioner "local-exec" {  # define local execution inside resource creation
    command = "ping 8.8.8.8"
  }
}
