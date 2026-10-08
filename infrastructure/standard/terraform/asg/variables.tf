# INSTANCE
variable "app-tier_ami" {}
variable "web-tier_ami" {}
variable "cpu" {
    default = "t3.micro"
}
variable "max_size" {
    default = 2
}
variable "min_size" {
    default = 1
}
variable "desired_cap" {
    default = 2
}
variable "asg_health_check_type" {
    default = "ELB"
}

# NETWORK
variable "web-tier_sg_id" {}
variable "app-tier_sg_id" {}
variable "pub_sub_1_id" {}
variable "pub_sub_2_id" {}
variable "pri_sub_3_id" {}
variable "pri_sub_4_id" {}
variable "web-tier-tg_arn" {}
variable "app-tier-tg_arn" {}