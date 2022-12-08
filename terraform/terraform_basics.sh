#!/bin/bash
####################################
# Terraform basics
# Author Artyom Ivanov
# Version 1.0
####################################

# Note! Terraform will keep described resources in the state as descibed in .tf files
# If one will change aws resource by his hands - terraform will delete this changes on the next apply-run
# Also we can export aws keys to env variables to not define them in terraform files
# To do so we can use ` export AWS_ACCESS_KEY_ID=(paste_here)`
# ` export AWS_SECRET_ACCESS_KEY=(paste_here)`
# ` export AWS_DEFAULT_REGION=us-west-1` 

# install - just download and unzip a binary file, copy it to bin folder

# init
terraform init

# read all files and plan some things from them and list this fings (whatif)
terraform plan

# now lets apply
terraform apply

# we will see file describing created resources "terraform.thstate"

# how to delete resources
terraform destroy

# lets test some functions
terraform console
file("userdata.sh")
# or
templatefile("userdata.tpl", { f_name = "win", l_name = "adm", names = ["vasya","kolya","john"] })

# and lets taint the resource to be re-created on the next terraform apply
terraform taint aws_instance.serv1
# and one more option to re-create a resource
terraform apply - replace aws_instance.serv1


# lets make some work with terraform remote state
# lets look at current terraform state of one resource
terraform state show resource_id
# list of resources in tfstate
terraform state list
# list all the resources
terraform state pull
# remove resource
terraform state rm resource_id
# move resource - change resource parameters wihtout re-creating it
terraform state mv resource_id
# overwrite state
terraform state push


# lets look at terraform workspaces
# this functionality helps us to experiment not on the prod)
# show current workspace
terraform workspace show
# list all the workspaces
terraform workspace list
# create a new workspace
terraform workspace new
# go to another workspace
terraform workspace select
# delete ws
terraform workspace delete
