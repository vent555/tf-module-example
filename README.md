# Terraform modules to deploy infrastructore in the AWS cloud
* Case study within the Andersen DevOps course.

## Changelog
* v0.1.0
    + add VPC module to deploy network
    * webserver-cluster module changes:
        + add data source terraform_remote_state to extract a data about VPC network
        * changed getting sunbets ids from the new data source
        + add vpc_id argument for aws_security_group resources
* v0.0.1 is used in product cluster.
