#==============================================================
# MÓDULO OBSERVABILITY: SNS y Alarmas Críticas de CloudWatch
#==============================================================

# SERVICIO DE NOTIFICACIÓN SIMPLE (SNS)
# ----------------------------------------------------------------------

# Tópico SNS para enviar notificaciones cuando se activan alarmas críticas.
resource "aws_sns_topic" "critical_alarms" {
  name = "${var.project_name}-${var.environment}-critical-alarms"

  tags = {
    Name        = "${var.project_name}-${var.environment}-aritical-alarms"
  }
}

# Suscripción al tópico SNS (usando correo electrónico)
# 🚨 NOTA: La suscripción debe ser confirmada manualmente por el correo electrónico
# proporcionado en la variable.
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.critical_alarms.arn
  protocol  = "email"
  endpoint  = var.email_for_notifications
}

# 2. ALARMAS DE CLOUDWATCH PARA APLICACIÓN (ALB)
# ----------------------------------------------------------------------

# Alarma: Latencia Elevada del ALB (Indica problemas en la aplicación)
resource "aws_cloudwatch_metric_alarm" "alb_latency_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ALB-HighLatency"
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


# 3. ALARMAS DE CLOUDWATCH PARA BASE DE DATOS (RDS)
# ----------------------------------------------------------------------

# Alarma: Uso de CPU Crítico en la Base de Datos
resource "aws_cloudwatch_metric_alarm" "rds_cpu_critical" {
  alarm_name          = "${var.project_name}-${var.environment}-RDS-CriticalCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300 # 5 minutos
  statistic           = "Average"
  threshold           = 90 # Si el CPU supera el 90% por 15 minutos (3x5)
  
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
  period              = 300 # 5 minutos
  statistic           = "Average"
  threshold           = 80 # Ajustar según el tipo de instancia y límite
  
  dimensions = {
    DBInstanceIdentifier = var.rds_db_instance_id
  }

  alarm_actions = [aws_sns_topic.critical_alarms.arn]
  ok_actions    = [aws_sns_topic.critical_alarms.arn]

}

