variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
  default     = "example-cluster"
}

variable "db_remote_state_bucket" {
  description = "The name  of the S3 bucket for the DB's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the DB's remote state in S3"
  type        = string
}

variable "vpc_remote_state_bucket" {
  description = "The name  of the S3 bucket for the vpc remote state"
  type        = string
}

variable "vpc_remote_state_key" {
  description = "The path for the vpc remote state in S3"
  type        = string
}

variable "server_port" {
  description = "Server port to listen http requests"
  type        = number
  default     = 8080
}

variable "instance_type" {
  description = "The type of EC2 Instance to run"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instance in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instance in the ASG"
  type        = number
}