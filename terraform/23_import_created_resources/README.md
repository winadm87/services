Create empty file and define resources to import
resource "aws_instance" "node1" {}
resource "aws_instance" "sg1" {}

Then run pare of commands
terraform import aws_instance.node1 instance_id
terraform import aws_security_group.sg1 sg_id

Next we have to make changes to .tf file.
We can view .tfstate file and take info from it to our .tf file
