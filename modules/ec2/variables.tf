variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to attach to the EC2 instance"
  type        = string
}

variable "tag_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "aws_azs" {
  type        = string
  description = "AWS Availability Zones"
}

variable "ebs_size" {
  type        = string
  description = "EBS volume size"
}