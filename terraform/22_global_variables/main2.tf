provider "aws" {
  region = "us-west-2"
}
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "path_to_bucket_here"
	key = "globalvars/terraform.tfstate"
	region = "us-west-2"  
  }
}
...
locals {  # set local variables to shorten global var names
  company_name = data.terraform_remote_state.global.outputs.company_name
  owner = data.terraform_remote_state.global.outputs.owner
  common_tags = data.terraform_remote_state.global.outputs.tags
}
....
resource "aws_vpc" "vpc2" {
  cidr_block = "10.0.0.0/16"
  tags = merge(local.common.tags, { Name = "newvpc1"} ) # merge local tags with one more
}
