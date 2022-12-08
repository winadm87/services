data "terraform_remote_state" "s3" { # to use outputs from remote state
  backend = "s3"
  config = {
    bucket = "copy_here" # bucket where to save .tfstate file
	key = "/folder/terraform.tfstate"  # filename and full path
	region = "us-west-2" # region where bucket was created
  }
}
module "s3_object" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git//modules/object"
  bucket = data.terraform_remote_state.s3.outputs.id
  key = var.file_name
  content = var.file_text
  tags = var.tags
} 
