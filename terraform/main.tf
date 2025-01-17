resource "aws_lb" "web_lb" {
    lifecycle {
        create_before_destroy = true
    }

    name               = "web-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.lb_sg.id]
    subnets            = aws_subnet.public_subnet[*].id

    tags = {
        Name = "web-lb"
    }
}

resource "aws_lb_target_group" "web_target_group" {
    name     = "web-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.custom_vpc.id

    stickiness {
        type    = "lb_cookie" 
        enabled = false       
    }

    health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"

    }
}

resource "aws_lb_listener" "web_listener" {
    load_balancer_arn = aws_lb.web_lb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
    }
}

resource "aws_autoscaling_group" "asg" {
    launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
    }

    min_size                  = var.min_instances
    max_size                  = var.max_instances
    desired_capacity          = var.desired_capacity
    vpc_zone_identifier       = aws_subnet.public_subnet[*].id
    target_group_arns         = [aws_lb_target_group.web_target_group.arn]
    health_check_type         = "ELB" 
    health_check_grace_period = 60 

    tag {
    key                 = "Name"
    value               = "WebServer"
    propagate_at_launch = true
    }
}

resource "aws_launch_template" "web_server" {
    name_prefix   = "web-server"
    image_id      = "ami-01a0731204136ddad"
    instance_type = var.instance_type
    key_name      = "aws_frankfurt_key"

    network_interfaces {
    security_groups = [aws_security_group.lb_sg.id]
    }

    monitoring {
    enabled = true
    }

    user_data = filebase64("setup_script.sh") # Load setup script
}
resource "aws_vpc" "custom_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
    Name = "custom-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    count                   = 2
    vpc_id                  = aws_vpc.custom_vpc.id
    cidr_block              = "10.0.${count.index}.0/24"
    map_public_ip_on_launch = true
    availability_zone       = data.aws_availability_zones.available.names[count.index]

    tags = {
    Name = "public-subnet-${count.index + 1}"
    }
}

resource "aws_security_group" "lb_sg" {
    name_prefix = "lb-sg"
    vpc_id = aws_vpc.custom_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.custom_vpc.id

    tags = {
    Name = "custom-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.custom_vpc.id

    tags = {
    Name = "public-rt"
    }
}

resource "aws_route" "default_route" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
    count          = 2
    subnet_id      = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_autoscaling_policy" "scale_up" {
    name                   = "scale-up"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 120
    autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
    name                   = "scale-in"
    scaling_adjustment     = -1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 120
    autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name                = "cpu_high"
    comparison_operator       = "GreaterThanThreshold"
    evaluation_periods        = 1
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/EC2"
    period                    = 60
    statistic                 = "Average"
    threshold                 = 50
    alarm_actions             = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
    alarm_name                = "cpu_low"
    comparison_operator       = "LessThanThreshold"
    evaluation_periods        = 1
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/EC2"
    period                    = 60
    statistic                 = "Average"
    threshold                 = 20
    alarm_actions             = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_cloudwatch_log_group" "web_server_logs" {
    name              = "/aws/ec2/web-server"
    retention_in_days = 7 
}

resource "aws_cloudwatch_log_stream" "web_server_stream" {
    name           = "web-server-stream"
    log_group_name = aws_cloudwatch_log_group.web_server_logs.name
}

resource "aws_sns_topic" "autoscaling_notifications" {
    name = "autoscaling-notifications"
}

resource "aws_sns_topic_subscription" "email_notifications" {
    topic_arn = aws_sns_topic.autoscaling_notifications.arn
    protocol  = "email"
    endpoint  = "shirak.gevorgyan.1999@gmail.com"
}

resource "aws_autoscaling_notification" "asg_notifications" {
    group_names = [aws_autoscaling_group.asg.name]
    notifications = [
        "autoscaling:EC2_INSTANCE_LAUNCH",
        "autoscaling:EC2_INSTANCE_TERMINATE"
    ]
    topic_arn = aws_sns_topic.autoscaling_notifications.arn
}
