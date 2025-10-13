#==============================================================
# MÓDULO OBSERVABILITY: Outputs
#==============================================================

output "sns_topic_arn" {
  description = "ARN del tópico SNS para notificaciones de alarmas críticas."
  value       = aws_sns_topic.critical_alarms.arn
}
