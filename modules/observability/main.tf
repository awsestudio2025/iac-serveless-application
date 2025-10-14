#==============================================================
# MÓDULO OBSERVABILITY
#==============================================================

# SERVICIO DE NOTIFICACIÓN SIMPLE (SNS)
# ----------------------------------------------------------------------
resource "aws_sns_topic" "critical_alarms" {
  name = "${var.project_name}-${var.environment}-critical-alarms"

  tags = {
    Name        = "${var.project_name}-${var.environment}-aritical-alarms"
  }
}

# Suscripción al tópico SNS (usando correo electrónico)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.critical_alarms.arn
  protocol  = "email"
  endpoint  = var.email_for_notifications
}

# ALARMAS DE CLOUDWATCH PARA APLICACIÓN (ALB)
# ----------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "alb_latency_high" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2.0
  
  dimensions = {
    TargetGroup = var.alb_target_group_arn
  }

  alarm_actions = [aws_sns_topic.critical_alarms.arn]
  ok_actions    = [aws_sns_topic.critical_alarms.arn]

  tags = {
    Environment = var.environment
  }
}


# ALARMAS DE CLOUDWATCH PARA BASE DE DATOS (RDS)
# ----------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_cpu_critical" {
  alarm_name          = "${var.project_name}-${var.environment}-RDS-CriticalCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  
  dimensions = {
    DBInstanceIdentifier = var.rds_db_instance_id
  }

  alarm_actions = [aws_sns_topic.critical_alarms.arn]
  ok_actions    = [aws_sns_topic.critical_alarms.arn]

  tags = {
    Environment = var.environment
  }
}

# Alarma: Conexiones de Base de Datos Excesivas
resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${var.project_name}-${var.environment}-RDS-HighConnections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  
  dimensions = {
    DBInstanceIdentifier = var.rds_db_instance_id
  }

  alarm_actions = [aws_sns_topic.critical_alarms.arn]
  ok_actions    = [aws_sns_topic.critical_alarms.arn]

}

