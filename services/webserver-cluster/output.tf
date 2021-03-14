#output ALB domain name 
output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "DNS name of the load balancer"
}

#need to apply shedule rules on ASG 
output "asg_name" {
  description = "The name of Auto Scaling Group"
  value = aws_autoscaling_group.test-group.name
}

#need to apply custom rules to permit traffic to ALB
output "alb_security_group_id" {
  description = "The ID of the Security Group attached to the ALB"
  value = aws_security_group.alb.id
}