#==============================================================
# MÓDULO ECS FARGATE: Cluster, Task Definition y Service
#==============================================================

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-Cluster"
  }
}

# Configuración de Balanceo de Carga

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project_name}-${var.environment}-app-tg"
  port        = var.app_port 
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_id
  target_type = "ip" 

  health_check {
   
    path                = "/health" 
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-App-TG"
  }
}

# ALB (Application Load Balancer)
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-${var.environment}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_public_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-ALB"
  }
}

# ALB Listener 
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ECS DEFINICION DE TAREA
# ----------------------------------------------------
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project_name}-${var.environment}-app-task"
  cpu                      = var.fargate_cpu 
  memory                   = var.fargate_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-app-container",
      image     = var.ecr_image_url 

      cpu       = tonumber(var.fargate_cpu)
      memory    = tonumber(var.fargate_memory)
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ],
      
      environment = [
 
        { name = "App_entorno", value = var.environment }
      ],


      secrets = [
        {

          name      = "DB_USERNAME", 
          valueFrom = "${var.secret_arn}:username::" 
        },
        {
          name      = "DB_PASSWORD",
          valueFrom = "${var.secret_arn}:password::"
        },
        {
          name      = "DB_ENGINE",
          valueFrom = "${var.secret_arn}:engine::"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-logs",
          "awslogs-region"        = data.aws_region.current.id,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  tags = {
    Name        = "${var.project_name}-${var.environment}-app-task"
  }

}


# ECS SERVICE
# ----------------------------------------------------
resource "aws_ecs_service" "app_service" {
  name            = "${var.project_name}-${var.environment}-app-service"
  cluster         = aws_ecs_cluster.app_cluster.name
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_app_private_ids
    security_groups  = [var.app_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "${var.project_name}-app-container"
    container_port   = var.app_port
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-Service"
  }
}

# CloudWatch

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "${var.project_name}-${var.environment}/app-logs"
  retention_in_days = 30
}