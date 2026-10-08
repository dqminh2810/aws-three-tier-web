# VPC
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  enable_dns_support =  true

  tags      = {
    Name    = "-vpc"
  }
}

# AVALABILITY ZONE 
data "aws_availability_zones" "available_zones" {}

# SUBNET
## create public subnet pub_sub_1
resource "aws_subnet" "pub_sub_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "pub_sub_1"
  }
}

## create public subnet pub_sub_2
resource "aws_subnet" "pub_sub_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "pub_sub_2"
  }
}

## create private app subnet pri-sub-3
resource "aws_subnet" "pri_sub_3" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.pri_sub_3_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-3"
  }
}

## create private app pri-sub-4
resource "aws_subnet" "pri_sub_4" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.pri_sub_4_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-4"
  }
}

## create private data subnet pri-sub-5
resource "aws_subnet" "pri_sub_5" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.pri_sub_5_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-5"
  }
}

## create private data subnet pri-sub-6
resource "aws_subnet" "pri_sub_6" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.pri_sub_6_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "pri-sub-6"
  }
}

# INTERNET GATEWAY
## create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "-igw"
  }
}

# NAT GATEWAY
## EIP A
resource "aws_eip" "eip-nat-a" {
    domain = "vpc"
    tags={
        Name = "eip-nat-a"
    }
}
## EIP B
resource "aws_eip" "eip-nat-b" {
    domain = "vpc"
    tags = {
      Name = "eip-nat-b"
    } 
}
## NAT GATEWAY A
resource "aws_nat_gateway" "nat-a" {
    allocation_id = aws_eip.eip-nat-a.id
    subnet_id = aws_subnet.pub_sub_1.id
    tags = {
      Name = "nat-a"
    }
    depends_on = [aws_internet_gateway.internet_gateway]
}
## NAT GATEWAY B
resource "aws_nat_gateway" "nat-b" {
    allocation_id = aws_eip.eip-nat-b.id
    subnet_id = aws_subnet.pub_sub_2.id
    tags={
        Name = "nat-b"
    }
    depends_on =  [aws_internet_gateway.internet_gateway]
}

# ROUTE TABLE
## PUBLIC
## create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "public-rt"
  }
}

## associate public subnet pub-sub-1 to public route table
resource "aws_route_table_association" "pub-sub-1_route_table_association" {
  subnet_id           = aws_subnet.pub_sub_1.id
  route_table_id      = aws_route_table.public_route_table.id
}

## associate public subnet pub-sub-1 to public route table
resource "aws_route_table_association" "pub-sub-2_route_table_association" {
  subnet_id           = aws_subnet.pub_sub_2.id
  route_table_id      = aws_route_table.public_route_table.id
}

## PRIVATE A
## create private route table a
resource "aws_route_table" "pri-rt-a" {
    vpc_id = aws_vpc.vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-a.id
    }

    tags = {
        Name = "pri-rt-a"
    }
}

## associate private subnet pri-sub-3 to private route table a
resource "aws_route_table_association" "pri-sub-3-with-Pri-rt-a" {
  subnet_id         = aws_subnet.pri_sub_3.id
  route_table_id    = aws_route_table.pri-rt-a.id
  
}

## associate private subnet pri-sub-4 to private route table a
resource "aws_route_table_association" "pri-sub-4-with-Pri-rt-a" {
  subnet_id         = aws_subnet.pri_sub_4.id
  route_table_id    = aws_route_table.pri-rt-a.id
}

## PRIVATE B
## create private route table b
resource "aws_route_table" "pri-rt-b" {
    vpc_id = aws_vpc.vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-b.id
    }

    tags = {
        Name = "pri-rt-b"
    }
}

## associate private subnet pri-sub-5 to private route table b
resource "aws_route_table_association" "pri-sub-5-with-Pri-rt-b" {
  subnet_id         = aws_subnet.pri_sub_5.id
  route_table_id    = aws_route_table.pri-rt-b.id
  
}

## associate private subnet pri-sub-6 to private route table b
resource "aws_route_table_association" "pri-sub-6-with-Pri-rt-b" {
  subnet_id         = aws_subnet.pri_sub_6.id
  route_table_id    = aws_route_table.pri-rt-b.id
}

# SECURITY GROUP
## External ALB
resource "aws_security_group" "external-alb_sg" {
    name= "external-alb_sg"
    description = "Enable http/https on port 80/443"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "http access"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "https access"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "outside"
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "external-alb_sg"
    }
}

## Web Tier
resource "aws_security_group" "web-tier_sg" {
    name= "web-tier_sg"
    description = "allow external ALB sg to access at port 80 http/https"
    vpc_id= aws_vpc.vpc.id
  
    ingress {
        description = "http access"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [ aws_security_group.external-alb_sg.id ]
    }
    ingress {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        #security_groups = [ aws_security_group.external-alb_sg.id ]
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port= 0
        to_port = 0
        protocol = -1
        cidr_blocks= ["0.0.0.0/0"]
    }
    tags={
        Name = "web-tier_sg"
    }
}

## Internal ALB
resource "aws_security_group" "internal-alb_sg" {
    name= "internal-alb_sg"
    description = "Enable http/https on port 80/443/22"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "http access"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [ aws_security_group.web-tier_sg.id ]
    }
    ingress {
        description = "https access"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = [ aws_security_group.web-tier_sg.id ]
    }
    ingress {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        #security_groups = [ aws_security_group.web-tier.id ]
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "outside"
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    
    }
    tags = {
      Name = "internal-alb_sg"
    }
}

## App Tier
resource "aws_security_group" "app-tier_sg" {
    name= "app-tier_sg"
    description = "Enable http/https on port 4000/22"
    vpc_id= aws_vpc.vpc.id
  
    ingress {
        description = "http access"
        from_port = 4000
        to_port = 4000
        protocol = "tcp"
        security_groups = [ aws_security_group.internal-alb_sg.id ]
    }
    ingress {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        #security_groups = [ aws_security_group.internal-alb_sg.id ]
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port= 0
        to_port = 0
        protocol = -1
        cidr_blocks= ["0.0.0.0/0"]
    }
    tags={
        Name = "app-tier_sg"
    }
}

## DB tier
resource "aws_security_group" "db_sg" {
    name = "db_sg"
    description = "Enable postgresql access on port 4510 frm app-tier_sg"
    vpc_id = aws_vpc.vpc.id

    ingress{
        description = "postgresql access"
        from_port = 4510
        to_port = 4510
        protocol = "tcp"
        security_groups = [ aws_security_group.app-tier_sg.id ]
    }
  
    egress {
        from_port= 0
        to_port=0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags={
    Name = "db_sg"
  }
}