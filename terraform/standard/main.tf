module "network" {
    source = "./network"
    aws_region = var.aws_region
    vpc_cidr = var.vpc_cidr
    pub_sub_1_cidr = var.pub_sub_1_cidr
    pub_sub_2_cidr = var.pub_sub_2_cidr
    pri_sub_3_cidr = var.pri_sub_3_cidr
    pri_sub_4_cidr = var.pri_sub_4_cidr
    pri_sub_5_cidr = var.pri_sub_5_cidr
    pri_sub_6_cidr = var.pri_sub_6_cidr
}

module "key" {
    source = "./key"
    key_name = var.key_name
    private_key_path = var.private_key_path
    public_key_path = var.public_key_path
}

# module "rds" {
#     source = "./rds"
#     # db_sg_id = module.network.db_sg_id
#     # pri_sub_5_id = module.network.pri_sub_5_id
#     # pri_sub_6_id = module.network.pri_sub_6_id
#     # db_username = var.db_username
#     # db_password = var.db_password
#     # db_port = var.db_port
# } 

module "ec2-instance" {
    source = "./ec2_instance"
    key_name = var.key_name
    private_key_path = var.private_key_path
    public_key_path = var.public_key_path
    app-tier_sg_id = module.network.app-tier_sg_id
    web-tier_sg_id = module.network.web-tier_sg_id
    pub_sub_1_id = module.network.pub_sub_1_id
    pub_sub_2_id = module.network.pub_sub_2_id
    pri_sub_3_id = module.network.pri_sub_3_id
    pri_sub_4_id = module.network.pri_sub_4_id
}

module "alb" {
    source = "./alb"
    vpc_id = module.network.vpc_id
    internal-alb_sg_id = module.network.internal-alb_sg_id    
    external-alb_sg_id = module.network.external-alb_sg_id
    pub_sub_1_id = module.network.pub_sub_1_id
    pub_sub_2_id = module.network.pub_sub_2_id
    pri_sub_3_id = module.network.pri_sub_3_id
    pri_sub_4_id = module.network.pri_sub_4_id
}

module "asg" {
    source = "./asg"
    app-tier_ami = module.ec2-instance.app-tier-with-dependencies_ami_id
    web-tier_ami = module.ec2-instance.web-tier-with-dependencies_ami_id
    web-tier_sg_id = module.network.web-tier_sg_id
    app-tier_sg_id = module.network.app-tier_sg_id
    pub_sub_1_id = module.network.pub_sub_1_id
    pub_sub_2_id = module.network.pub_sub_2_id
    pri_sub_3_id = module.network.pri_sub_3_id
    pri_sub_4_id = module.network.pri_sub_4_id
    web-tier-tg_arn = module.alb.web-tier-tg_arn
    app-tier-tg_arn = module.alb.app-tier-tg_arn
}
