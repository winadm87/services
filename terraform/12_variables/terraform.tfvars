region = "us-west-2"
instance_type = "t2.micro"
enabled_detailed_monitoring = false
common_tags = {
  Owner = "winadm"
  Project = "123"
  CostCenter = "manymoney"
  Environment = "dev"
}
allow_ports = ["80", "443", "3389"]
