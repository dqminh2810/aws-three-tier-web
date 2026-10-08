variable "aws_region" {
    description = "The AWS region to deploy the resources in"
    type = string
    default = "us-east-1"
  
}
variable "key_name" {
  description = "The name of the SSH key pair to use."
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file for SSH access."
  type        = string
}

variable "public_key_path" {
  description = "The path to the public key file for SSH access."
  type        = string
}
variable "vpc_cidr" {}
variable "pub_sub_1_cidr" {}
variable "pub_sub_2_cidr" {}
variable "pri_sub_3_cidr" {}
variable "pri_sub_4_cidr" {}
variable "pri_sub_5_cidr" {}
variable "pri_sub_6_cidr" {}
variable "db_username" {}
variable "db_password" {}
variable "db_port" {}