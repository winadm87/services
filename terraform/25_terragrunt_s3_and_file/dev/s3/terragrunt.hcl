include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git//."
}

inputs = {
  bucket = "terragrunt-test-bucket-dev"
  tags = {
    Owner       = "winadm"
    Environment = "dev"
  }
}
