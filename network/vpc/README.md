# The terraform template module to deploy a VPC network in the AWS cloud

# Content

## aws_vpc
creates a network for infrastructure.

## aws_subnet
creates subnets based on input vars from root module. Private and public subnets are created.

## aws_route_table
One routing table is created for each public and private subnets' types.

## aws_route_table_association
One route_table association for each subnet is created.

## aws_route
linkes public routing table with internet gate way. Creates a default route to Internet access. 

## aws_internet_gateway
provides Internet access.

## Outputs
* vpc_id
* private and public subnets