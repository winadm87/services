lets work with conditions and lookups. below terraform IF statement
instance_type = var.env == "prod" ? "t2.large" : "t2.micro"
                ^if     ^confition   ^if yes      ^ if no
X = condition ? value_if_true : value_if_false
