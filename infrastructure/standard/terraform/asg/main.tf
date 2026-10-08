# APP TIER
resource "aws_launch_template" "app-tier_lt" {
    image_id = var.app-tier_ami
    instance_type = var.cpu
    vpc_security_group_ids = [var.app-tier_sg_id]
}

resource "aws_autoscaling_group" "app-tier_asg" {
    max_size = var.max_size
    min_size = var.min_size
    desired_capacity = var.desired_cap
    health_check_grace_period = 300
    health_check_type = var.asg_health_check_type
    vpc_zone_identifier = [var.pri_sub_3_id,var.pri_sub_4_id]
    target_group_arns = [ var.app-tier-tg_arn ]
    enabled_metrics = [ 
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
    ]
    metrics_granularity = "1Minute"
    launch_template {
        id      = aws_launch_template.app-tier_lt.id
        version = aws_launch_template.app-tier_lt.latest_version 
    }
    depends_on = [aws_launch_template.app-tier_lt]
}

resource "aws_autoscaling_policy" "app-tier_asg_scale_up" {
    name = "app-tier-asg-policy"
    autoscaling_group_name = aws_autoscaling_group.app-tier_asg.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
    depends_on = [aws_autoscaling_policy.app-tier_asg_scale_up]
}

# WEB TIER
resource "aws_launch_template" "web-tier_lt" {
    image_id = var.web-tier_ami
    instance_type = var.cpu
    vpc_security_group_ids = [var.web-tier_sg_id]
}

resource "aws_autoscaling_group" "web-tier_asg" {
    max_size = var.max_size
    min_size = var.min_size
    desired_capacity = var.desired_cap
    health_check_grace_period = 300
    health_check_type = var.asg_health_check_type
    vpc_zone_identifier = [var.pub_sub_1_id,var.pub_sub_2_id]
    target_group_arns = [ var.web-tier-tg_arn ]
    enabled_metrics = [ 
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
    ]
    metrics_granularity = "1Minute"
    launch_template {
        id      = aws_launch_template.web-tier_lt.id
        version = aws_launch_template.web-tier_lt.latest_version 
    }
    depends_on = [aws_launch_template.web-tier_lt]
}

resource "aws_autoscaling_policy" "web-tier_asg_scale_up" {
    name = "web-tier-asg-policy"
    autoscaling_group_name = aws_autoscaling_group.web-tier_asg.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
    depends_on = [aws_autoscaling_group.web-tier_asg]
}