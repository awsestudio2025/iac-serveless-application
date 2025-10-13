#==============================================================
# OUTPUT SECRETS MANAGER
#==============================================================

    output "rds_secret_arn" {
        description = "ARN del Secreto de RDS en Secrets Manager. Necesario para el Rol de Ejecución de Tarea de ECS y para el Task Definition."
        value       = aws_secretsmanager_secret.rds_credentials.arn
    }