# The terraform template module to deploy a webserver-cluster in the AWS cloud
* Case study within the Andersen DevOps course.

# Content

## Auto Scaling Group
* launch from 2 to 10 elastic compute cloude instances in depend on load.

### aws_launch_configuration resource
launches EC2 instances which are web-servers with application. 
* user_data param point to application to deploy;
* aws_security_group.instance ataches to EC2 instance to permit input traffic.

## Application Load Balancer consists of:
### aws_lb_listener
is used to perform http requests.

### aws_lb_listener_rule
applyes rules to target group to forward requests.

### aws_target_group 
* is attached to ASG with the EC2 instances which perform requests;
* checks health of EC2 instances.

### aws_security_group.alb
is not a part of ALB but attaches to it.
* aws_security_group_rule.allow_http_inbound is atteched to security group; permits input http traffic;
* aws_security_group_rule.allow_all_outbound is atteched to security group; permits all outbound traffic.

## Data sources
### terraform_remote_state.vpc
is used to extract information about network to deploy infrastructure.

### terraform_remote_state.db
is used to extract data to connect to database.

### template_file.user_data
is used to modify user data by extracting DB connection parameters and transfering it to user data config files.
