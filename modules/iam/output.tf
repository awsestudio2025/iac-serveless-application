#==============================================================
# MÓDULO IAM: Outputs
#==============================================================

    output "ecs_execution_role_arn" {
        description = "ARN del rol de ejecucion de la tarea ECS Fargate."
        value       = aws_iam_role.ecs_execution_role.arn
    }

    output "ecs_task_role_arn" {
        description = "ARN del rol de tarea ECS Fargate (aplicacion)."
        value       = aws_iam_role.ecs_task_role.arn
    }

    output "rds_monitoring_role_arn" {
        description = "ARN del Rol de IAM requerido por RDS para el Monitoreo Mejorado (Enhanced Monitoring)."
        value       = aws_iam_role.rds_monitoring_role.arn
    }
