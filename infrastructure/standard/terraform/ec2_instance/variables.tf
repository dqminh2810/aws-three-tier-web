variable "ami" {
    default = "ami-0ecb62995f68bb549"
}
variable "cpu" {
    default = "t3.micro"
}

variable key_name {}
variable private_key_path {}
variable public_key_path {}

variable "app-tier_sg_id" {}
variable "web-tier_sg_id" {}
variable "pub_sub_1_id" {}
variable "pub_sub_2_id" {}
variable "pri_sub_3_id" {}
variable "pri_sub_4_id" {}