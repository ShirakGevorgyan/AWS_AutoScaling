variable "aws_region" {
    description = "AWS region to deploy resources"
    default     = "eu-central-1"
}

variable "instance_type" {
    description = "EC2 instance type"
    default     = "t2.micro"
}

variable "min_instances" {
    description = "Minimum number of instances in Auto Scaling group"
    default     = 2
}

variable "max_instances" {
    description = "Maximum number of instances in Auto Scaling group"
    default     = 6
}

variable "desired_capacity" {
    description = "Desired number of instances in Auto Scaling group"
    default     = 2
}
