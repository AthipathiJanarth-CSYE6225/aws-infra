resource "aws_lb" "webapp_lb" {
  name            = "webapp-lb"
  subnets         = [for subnet in aws_subnet.public_subnet : subnet.id]
  security_groups = [aws_security_group.load_balancer.id]
}
resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.webapp_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name        = "webapp-tg"
  port        = var.APP_PORT
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.myVpc.id

  health_check {
    path     = "/healthz"
    protocol = "HTTP"
  }
}
resource "aws_autoscaling_attachment" "application_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.application.name
  lb_target_group_arn   = aws_lb_target_group.webapp_tg.arn
}