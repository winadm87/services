variable "file_name" {
  default = "test_file.txt"
}
variable "file_text" {
  default = "created by terrafrom"
}
variable "tags" {
  default = {
    Owner = "winadm"
	Environment = "dev"
  }
}
