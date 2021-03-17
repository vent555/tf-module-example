output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this[0].id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "public_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.public.*.id
}