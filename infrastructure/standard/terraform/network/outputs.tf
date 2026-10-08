output "region" {
  value = var.aws_region
}

# VPC
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# SUBNET
output "pub_sub_1_id" {
  value = aws_subnet.pub_sub_1.id
}
output "pub_sub_2_id" {
  value = aws_subnet.pub_sub_2.id
}
output "pri_sub_3_id" {
  value = aws_subnet.pri_sub_3.id
}

output "pri_sub_4_id" {
  value = aws_subnet.pri_sub_4.id
}

output "pri_sub_5_id" {
  value = aws_subnet.pri_sub_5.id
}

output "pri_sub_6_id" {
    value = aws_subnet.pri_sub_6.id 
}

# INTERNET GATEWAY
output "igw_id" {
    value = aws_internet_gateway.internet_gateway.id
}

# NAT GATEWAY
output "ngw-a_id" {
    value = aws_nat_gateway.nat-a.id
}

output "ngw-b_id" {
    value = aws_nat_gateway.nat-b.id
}

# SECURITY GROUP
output "external-alb_sg_id" {
    value = aws_security_group.external-alb_sg.id
}

output "web-tier_sg_id" {
    value = aws_security_group.web-tier_sg.id
}

output "internal-alb_sg_id" {
    value = aws_security_group.internal-alb_sg.id
}

output "app-tier_sg_id" {
    value = aws_security_group.app-tier_sg.id
}

output "db_sg_id" {
    value = aws_security_group.db_sg.id
}