## PUBLIC LOAD BALANCER 

# Open to the internet security group for the public load balancer
resource "aws_security_group" "sg_public_alb" {
  vpc_id      = var.vpc_id
  description = "Security group for open to the internet"
  name        = "${var.owner_id}-alb-sg"

  #HTTP
  ingress {
    description = "Standard http incoming"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ports and protocols to go out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load balancer
resource "aws_lb" "alb" {
  name               = "${var.owner_id}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_public_alb.id]
  subnets            = var.pub_subnets

  enable_deletion_protection = false
}

# Target group
resource "aws_lb_target_group" "ltg_port80" {
  name     = "${var.owner_id}-ltg-port80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
  }
}

# Port 80 listener
resource "aws_lb_listener" "lblistener_port80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ltg_port80.arn
  }
}

resource "aws_lb_target_group_attachment" "ltgattachment-workers" {
  count            = length(aws_instance.worker_ec2)
  target_group_arn = aws_lb_target_group.ltg_port80.arn
  target_id        = aws_instance.worker_ec2[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ltgattachment-manager" {
  target_group_arn = aws_lb_target_group.ltg_port80.arn
  target_id        = aws_instance.manager_ec2.id
  port             = 80
}
