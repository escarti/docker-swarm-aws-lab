resource "aws_security_group" "sg_ecs" {
  vpc_id      = var.vpc_id
  description = "Security group for ECS services in cluster"
  name        = "${var.owner_id}-sg-ecs"

  ingress {
    description = "Allow ssh incoming connections"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  #HTTP
  ingress {
    description     = "Standard http incoming"
    from_port       = var.host_port
    to_port         = var.host_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_public_alb.id, ]
  }

  ingress {
    description = "ICMP echo reply"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = var.allowed_ips
  }

  ingress {
    description = "Allow all traffic from self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }


  egress {
    description = "Allow all ports and protocols to go out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.owner_id}-ecs-cluster"
}

data "template_file" "simple_flask_definition" {
  template = file("${path.module}/templates/simple_flask_web.json")

  vars = {
    image          = var.image
    host_port      = var.host_port
    container_port = var.container_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
  }
}

resource "aws_ecs_task_definition" "simple_flask_web_task" {
  family                   = "${var.owner_id}-sfw-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.simple_flask_definition.rendered
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
}

resource "aws_ecs_service" "simple_flask_web_service" {
  name            = "${var.owner_id}-sfw-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.simple_flask_web_task.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.sg_ecs.id]
    subnets         = var.priv_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ltg_port80.arn
    container_name   = "simple_flask_web"
    container_port   = var.host_port
  }

  depends_on = [aws_lb_listener.lblistener_port80, aws_security_group.sg_ecs]

}