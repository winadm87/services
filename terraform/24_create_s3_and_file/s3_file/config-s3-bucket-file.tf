provider "aws" {
  region = "us-west-2"
  assume_role = {
    role_arn = "arn---copy-here"  # define aws account
  }
}
terraform {
  backend "s3" {
    bucket = "copy_here" # bucket where to save .tfstate file
	key = "/folder/terraform.tfstate"  # filename and full path
	region = "us-west-2" # region where bucket was created
  }
}
