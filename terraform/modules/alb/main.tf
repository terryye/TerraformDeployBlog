
resource "aws_lb" "webapp_alb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_target_group.arn
  }
}

resource "aws_lb_target_group" "webapp_target_group" {
  name     = "webapp-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

output "target_group_arn" {
  value = aws_lb_target_group.webapp_target_group.arn
}