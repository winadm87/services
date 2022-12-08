variable "bucket_name" {
  default = "some_unique_name"
}
variable "tags" {
  default = {
    Owner = "winadm"
	Environment = "dev"
  }
}
