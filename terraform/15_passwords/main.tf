provider "aws" {
  region = "us-west-2"
}
variable "pass_changer" { # define var on which change pass will be regenerated
  default = "pass1"
}
resource "random_sring" "rds_password" {
  length = 12
  special = true  # include special charachters
  override_special = "!@$&"  # include only this charachters
  keepers = {
    keeper1 = var.pass_changer # define pass change keeper
  }
}
resource "aws_ssm_parameter" "rds_password" {
  name = "/prod/mysql"
  description = "Master pass for mysql"
  type = "SecureString"  # store encrypted
  value = random_string.rds_password.result 
}
data "aws_ssm_parameter" "my_rds_password" {
  name = "/prod/mysql"
  depends_on = [aws_ssm_parameter.rds_password]
}
output "rds_password" {
  value = data.aws_ssm_parameter.my_rds_password.value
}
resource "aws_db_instance" "mydb" {
  identifier = "prod-rds"
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "prod"
  username = "administrator"
  password = data.aws_ssm_parameter.my_rds_password.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
  apply_immediately = true 
}
