# Variables
variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  default = "10.0.2.0/24"
}

variable "ami_id" {
  default = "ami-0c94855ba95c71c99"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "efs_performance_mode" {
  default = "generalPurpose"
}

variable "efs_throughput_mode" {
  default = "bursting"
}

variable "efs_encrypted" {
  default = true
}

variable "efs_lifecycle_policy" {
  default = "{\"TransitionToIA\": \"AFTER_30_DAYS\"}"
}

variable "s3_bucket_name" {
  default = "example-s3-bucket"
}

