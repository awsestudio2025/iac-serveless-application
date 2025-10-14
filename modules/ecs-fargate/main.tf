#==============================================================
# MÓDULO ECS FARGATE
#==============================================================

    data "aws_region" "current" {}
    data "aws_caller_identity" "current" {}

# CloudWatch Log Group 
# ----------------------------------------------------
    resource "aws_cloudwatch_log_group" "app_logs" {
        name              = "/ecs/${var.project_name}-${var.environment}-logs"
        retention_in_days = 90
        
        tags = {
            Environment = var.environment
        }
    }

# ECS Cluster
# ----------------------------------------------------
    resource "aws_ecs_cluster" "app_cluster" {
        name = "${var.project_name}-${var.environment}-cluster"
        
        setting {
            name  = "containerInsights"
            value = "enabled"
        }

        tags = {
            Name = "${var.project_name}-${var.environment}-ecs-Cluster"
        }
    }

# Configuración de Balanceo de Carga (ALB/Target Group)
# ----------------------------------------------------
    resource "aws_lb_target_group" "app_tg" {
        name        = "${var.project_name}-${var.environment}-app-tg"
        port        = var.app_port 
        protocol    = "HTTP"
        vpc_id      = var.aws_vpc_id # Mantengo la variable tal como usted la definió
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
  
  #ROLES DE IAM CONECTADOS
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

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
          name      = "DB_CREDENTIALS", 
          valueFrom = var.secret_arn 
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"   = aws_cloudwatch_log_group.app_logs.name,
          "awslogs-region"  = data.aws_region.current.id,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = {
    Name = "${var.project_name}-${var.environment}-app-task"
  }
}

# Servicio ECS
# ----------------------------------------------------
resource "aws_ecs_service" "app_service" {
  name            = "${var.project_name}-${var.environment}-app-service"
  cluster         = aws_ecs_cluster.app_cluster.name
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_private_ids
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

# Auto Escalado
# ----------------------------------------------------
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1 
  resource_id        = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.app_service.name}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
}
resource "aws_appautoscaling_policy" "ecs_cpu_scaling_policy" {
  name               = "${var.project_name}-${var.environment}-cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 50.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
