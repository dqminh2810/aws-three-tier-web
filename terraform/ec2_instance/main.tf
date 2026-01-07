resource "aws_instance" "app-tier_instance" {
    ami           = var.ami
    instance_type = var.cpu
    key_name      = var.key_name
    user_data     = file("base_setup/install-app-tier-server.sh")
    vpc_security_group_ids = [var.app-tier_sg_id]
    subnet_id     = var.pri_sub_3_id
}

resource "aws_ami_from_instance" "app-tier-with-dependencies_ami" {
    name = "app-tier-with-dependencies-ami" # Dynamic name to force recreation on update
    source_instance_id = aws_instance.app-tier_instance.id
    depends_on = [aws_instance.app-tier_instance]
}

resource "aws_instance" "web-tier_instance" {
    ami           = aws_ami_from_instance.app-tier-with-dependencies_ami.id
    instance_type = var.cpu
    key_name      = var.key_name
    user_data     = file("base_setup/install-web-tier-server.sh")
    vpc_security_group_ids = [var.app-tier_sg_id]
    subnet_id     = var.pub_sub_1_id
}

resource "aws_ami_from_instance" "web-tier-with-dependencies_ami" {
    name = "app-tier-with-dependencies-ami}" # Dynamic name to force recreation on update
    source_instance_id = aws_instance.app-tier_instance.id
    depends_on = [aws_instance.web-tier_instance]
}