provider aws {
  region = "us-west-2"
}
data "aws_availability_zones" "available" {} # get list of zones in region
data "aws_ami" "latest_amazon_linux" {  # get latest ami id
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_security_group" "my_webserver" { # create security group
  name = "dynamic security group"
  dynamic "ingress" {
    for_each = ["80","443"]
    content {
	  from_port = ingress.value
	  to_port = ingress.value
	  protocol = "tcp"
	  cidr_blocks = ["0.0.0.0/0"]
	}
  }
  egress {   # outgoing traffic
    from_port = 0
	to_port = 0
	protocol = "-1"  # any protocol
	cir_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Dynamic SecurityGroup"
	Owner = "winadm"
  }
}
resource "aws_launch_configuration" "web" { # create launch configuration for autoscaling group
//  name = "WebServer-HA-LC"
  name_prefix = "WebServer-HA-LC-" # define name prefix, that will be generated automatically to avoid problems with "resourse cannot be created"
  image_id = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
  security_groups = [aws_security_group.my_webserver.id]
  user_data = file("userdata.sh") # get userdata from external file
  lifecycle {
    create_before_destoy = true # green\blue deployment
  }
}
resource "aws_autoscaling_group" "web" { # create autoscaling group
  name = "ASG-${aws_launch_configuration.web.name}" # create dependancy on launch configuration
  launch_configuration = aws_launch_configuration.web.name
  min_size = 2
  max_size = 2
  min_elb_capacity = 2 #health checks from load balancer
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id] # define two subnets to run instances at
  health_check_type = "ELB" #ping to our webpage
  load_balancers = [aws_elb.web.name] # define load balancer 
  dynamic "tag" { # define dynamic tags
    for_each = {
	Name = "ASG Web Server"
	Owner = "winadm"
	TAGKEY = "TAGVALUE"
	}
  content {
    key = tag.key
	value = tag.value
	propagate_at_launch = true
  }
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_elb" "web" { # create load balancer
  name = "webserver-ha-elb"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]] # define first two zones to run elb at
  security_group = [aws_security_group.my_webserver.id]
  listener{
    lb_port = 80
	lb_protocol = "http"
	instance_port = 80
	instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
	unhealthy_treshold = 2
	timeout = 3
	target = "HTTP:80/"
	interval = 10
  }
  tags = {
    Name = "Webserver-HA-ELB"
  }
}
resource "aws_default_subnet" "default_az1" { # get subnet from qws resources
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_default_subnet" "default_az2" { # get subnet from qws resources
  availability_zone = data.aws_availability_zones.available.names[1]
}
output "web_loadbalancer_url" { # print url for created webserver - elb
  value = aws_elb.web.dns_name
}
