variable "region" {
  description = "Please enter aws region: "
  default = "us-west-2" # set default variable value
} 
//variable "region" # define variable, if empty - will be asked on run
variable "instance_type" {
  description = "Enter instance type"
  default = "t3.micro"
}
variable "allow_ports" {
  description = "list ports to open"
  type = list # we need list of values
  default = ["80", "443", "22"]
}
variable "detailed_monitoring" {
  description = "enable detailed monitoring for instance"
  type = bool # we need boolean true or false
  default = true
}
variable "common_tags" {
  description = "common tags for resources"
  type = map
  default = {
    Owner = "winadm"
	Project = "123"
	Costcenter = "manymoney"
	Environment = "dev"
  }
}
