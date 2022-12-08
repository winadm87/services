provider "aws" {
  region = "us-west-2"
}
variable "env" {
  default = "prod"
}
variable "prod_owner" {
  default = "winadm"
}
variable "no_prod_owner" {
  default = "nowinadm"
}
resource "aws_instance" "supserver" {
  ami = paste_here
  instance_type = var.env == "prod" ? "t3.large" : "t3.small"
  tags = {
    Name = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.no_prod_owner
  }
}
resource "aws_instance" "devserver" {
  count = var.env == "dev" ? 1 : 0 # create instance only if dev env defined
  ami = paste_here
  instance_type = "t3.micro"
  tags = {
    Name = "devserver"
  }
}
