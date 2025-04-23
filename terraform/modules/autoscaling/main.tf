resource "aws_autoscaling_group" "webapp_asg" {
  name                      = "webapp-asg"
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "Scale-up when CPU > 70%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "Scale-down when CPU < 30%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

variable "subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "launch_template_id" {
  type = string
}