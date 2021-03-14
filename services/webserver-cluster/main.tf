#local var expands only on current module
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

#Each EC2 instance locates in own VPC subnet
#which locates in isolate availability zone.
#Request information about VPC 
#which will use to auto scaling launch resources.
data "aws_vpc" "default" {
  default = true
}
#Use one more data source to extract VPC subnets from whole VPC cloud 
data "aws_subnet_ids" "default" {
  #link to aws_vpc data source by id  
  vpc_id = data.aws_vpc.default.id
}

#Data source lets pick information about mysql database
data "terraform_remote_state" "db" {
  backend = "s3"

  config  = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "eu-central-1"
  }
}

#Data source template_file creates user data file with bash script
#Transher vars into script-file, gain complite bash script
data "template_file" "user_data" {
  #Then we call this module from stage or prod,
  #path to user-data.sh will picked from stage/prod module dir,
  #but in reality file resides in one folder with current module
  #that is why we use "${path.module}/"
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }
} 

#Application load balancer
resource "aws_lb" "example" {
  name                  = var.cluster_name
  load_balancer_type    ="application"
  #extract VPC zone ids from data source aws_subnet_ids
  subnets               = data.aws_subnet_ids.default.ids
  #link to traffic policy for ALB
  security_groups       = [aws_security_group.alb.id]
}

#The traffic policy group for ALB
resource "aws_security_group" "alb" {
  #The name consist of the var value and "-alb", 
  #because there are two aws_security_group used in the config
  name = "${var.cluster_name}-alb"
}
#permit http requests rule
resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  #rule applied to policy group for ALB
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}
#permit any output rule
resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  #rule applied to policy group for ALB
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

#ALB consist of three parts:
#1. Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"
  
  #Default action is response with "404: not found"
  default_action {
    type = "fixed-response"

    fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code  = 404
    }
  }
}
#2. Listener rule
resource "aws_lb_listener_rule" "asg" {
  listener_arn  = aws_lb_listener.http.arn
  priority      = 100

  condition {
    path_pattern {
        values  = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
#3. Target group
resource "aws_lb_target_group" "asg" {
  name      = var.cluster_name
  port      = var.server_port
  protocol  = "HTTP"
  vpc_id    = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#auto scaling group to launch EC2 instance on demand
resource "aws_autoscaling_group" "test-group" {
  #use link as launch_configuration name
  launch_configuration  = aws_launch_configuration.test.name
  #extract VPC zone ids from data source aws_subnet_ids
  vpc_zone_identifier   = data.aws_subnet_ids.default.ids
  #link to Target group in ALB
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  #from 2 to 10 ec2 instance will launched
  min_size = var.min_size
  max_size = var.max_size

  #Name are propogated on the launched EC2 instances
  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

}

#use aws_launch_configuration instead aws_instance =>
#change ami to image_id, vpc_security_group_ids to security_groups
resource "aws_launch_configuration" "test" {
  image_id          = "ami-0767046d1677be5a0"
  instance_type     = var.instance_type
  #to link ec2-instance with security group:
  security_groups   = [ aws_security_group.instance.id ]
  
  #get result from data source template_file
  user_data = data.template_file.user_data.rendered

  #configuration param is used then auto scaling implemented
  lifecycle {
    create_before_destroy = true
  }
}

#this resource exports attribute "id" to refer on them.
resource "aws_security_group" "instance" {
  #The name consist of the var value and "-instance", 
  #because there are two aws_security_group used in the config
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }  
}