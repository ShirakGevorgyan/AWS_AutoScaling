output "load_balancer_dns" {
    description = "The DNS name of the load balancer"
    value       = aws_lb.web_lb.dns_name
}

output "autoscaling_group_name" {
    description = "The name of the Auto Scaling group"
    value       = aws_autoscaling_group.asg.name
}
