# lets fill variables from cli
terraform apply -var="region=us-east-1"
terraform apply -var="region=us-east-1" -var="instance_type=t2.micro"
export TF_VAR_region=us-west-2 # export to env and apply on the run from there

# ... and now lets run apply with created file
terraform apply -var-file="terraform.tfvars"
