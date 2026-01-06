module "network" {
    source = "../modules/network"
    aws_region=var.aws_region
    vpc_cidr = var.vpc_cidr
    pub_sub_1_cidr =  var.pub_sub_1_cidr
    pub_sub_2_cidr =   var.pub_sub_2_cidr
    pri_sub_3_cidr =   var.pri_sub_3_cidr
    pri_sub_4_cidr =   var.pri_sub_4_cidr
    pri_sub_5_cidr =   var.pri_sub_5_cidr
    pri_sub_6_cidr =   var.pri_sub_6_cidr
}

module "key" {
    source = "../modules/key"
    key_name=var.key_name
    private_key_path=var.private_key_path
    public_key_path=var.public_key_path
}

module "rds" {
    source = "../modules/rds"
} 

module "ec2-instance" {
    source = "../modules/ec2-instance"
}

module "alb" {
    source = "../modules/alb"
}