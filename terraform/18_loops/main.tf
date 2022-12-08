provider "aws" {
  region = "us-west-1"
}
variable "aws_users" {
  description = "list of users"
  default = ["valera", "dima", "masha"]
}
resource "aws_iam_user" "users" {
  count = length(var.aws_users) # count all elements in variable list
  name = element(var.aws_users, count.index)
}
output "created_users" {
  value = [
    for i in aws_iam_user.users:  # use of for-loop
	  "Username: ${i.name} has arn ${i.arn}"
  ]
}
output "created_users_map" {
  value = {
    for i in aws_iam_user.users:
	  i.unique_id => i.id   # use map
  }
}
output "created_short_users" {
  value = [
    for i in aws_iam_user.users:  # use for loop
	  i.name
	  if length(i.name) == 4 # use if-loop, select username with 4 charachters only
  ]
}
resource "aws_instance" "servers" {
  count = 3
  ami = paste_here
  instance_type = "t3.micro"
  tags = {
    Name = "Server number $(count.index + 1)" # to start from 1 not 0
  }
}
output "serverinfo" {
  value = {
    for server in aws_instance.servers :
	  server.id => server.public_ip  # map of instance parameters
  }
}
