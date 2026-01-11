aws_region = "us-east-1"

key_name          = "ec2-instance-ssh-key"
private_key_path  = "key/ssh/ec2-instance-ssh-key"
public_key_path   = "key/ssh/ec2-instance-ssh-key.pub"

vpc_cidr = "10.0.0.0/16"
pub_sub_1_cidr =  "10.0.0.0/24"
pub_sub_2_cidr =   "10.0.10.0/24"
pri_sub_3_cidr =   "10.0.20.0/24"
pri_sub_4_cidr =   "10.0.30.0/24"
pri_sub_5_cidr =   "10.0.40.0/24"
pri_sub_6_cidr =   "10.0.50.0/24"

db_username = "admin"
db_password = "password"
db_port = 4510