output "web-tier-lb_arn" {
    value = aws_lb.web-tier_lb.arn
}

output "app-tier-lb_arn" {
    value = aws_lb.app-tier_lb.arn
}

output "web-tier-tg_arn" {
    value = aws_lb_target_group.web-tier_tg.arn
}

output "app-tier-tg_arn" {
    value = aws_lb_target_group.app-tier_tg.arn
}