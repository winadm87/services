provider aws {
  region = "us-west-2" 
}
locals {
  newprojectname = "${var.environment} on the ${var.project_name}" # define local variable
}
resource "aws_eip" "my_static_ip" {
  tags = {
    Name = "StaticIP"
	Owner = "winadm"
	Project = "${var.environment} - ${var.project_name}"
	newproject = local.newprojectname  # use local variable
}
variable "environment" {
  default = "DEV"
}
variable "project_name" {
  default = "POJECO"
}
variable = "owner" {
  default = "winadm"
}
