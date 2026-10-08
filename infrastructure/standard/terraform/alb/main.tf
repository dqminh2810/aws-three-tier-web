# APP_TIER
## Load Balancer
resource "aws_lb" "app-tier_lb" {
    name = "app-tier-internal-lb"
    internal = true
    load_balancer_type = "application"
    security_groups = [var.internal-alb_sg_id]
    subnets = [var.pri_sub_3_id,var.pri_sub_4_id]
    enable_deletion_protection = false
}

## Target Group
resource "aws_lb_target_group" "app-tier_tg" {
    name = "app-tier-tg"
    target_type = "instance"
    port = 4000
    protocol = "HTTP"
    vpc_id = var.vpc_id
    
    health_check {
      enabled = true
      interval = 300
      path = "/"

      timeout = 60
      matcher = 200
      healthy_threshold = 2
      unhealthy_threshold = 5
    }
    lifecycle {
      create_before_destroy = true
    }
}

## Listener
resource "aws_lb_listener" "app-tier_alb_http_listener" {
    load_balancer_arn = aws_lb.app-tier_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app-tier_tg.arn
    }
}


## WEB-TIER
## Load Balancer
resource "aws_lb" "web-tier_lb" {

    name = "web-tier-internal-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.external-alb_sg_id]
    subnets = [var.pub_sub_1_id,var.pub_sub_2_id]
    enable_deletion_protection = false
}

## Target Group
resource "aws_lb_target_group" "web-tier_tg" {
    name = "web-tier-tg"
    target_type = "instance"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
    
    health_check {
      enabled = true
      interval = 300
      path = "/"

      timeout = 60
      matcher = 200
      healthy_threshold = 2
      unhealthy_threshold = 5
    }
    lifecycle {
      create_before_destroy = true
    }
}

## Listener
resource "aws_lb_listener" "web-tier_alb_http_listener" {
    load_balancer_arn = aws_lb.web-tier_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.web-tier_tg.arn
    }
}