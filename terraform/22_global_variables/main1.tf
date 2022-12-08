provider "aws" {
  region = "us-west-2"
}
terraform { # define place for terraform remote state
  backend "s3" {
    bucket = "path_to_bucket_here"
	key = "globalvars/terraform.tfstate"
	region = "us-west-2"
}
output "company_name" {
  value = "Roga"
}
output "owner" {
  value = "winadm"
}
output "tags" {
  value = {
    Project = "123-2022"
    ConstCenter = "manymoney"
	Country = "Georgia"
  }
}
