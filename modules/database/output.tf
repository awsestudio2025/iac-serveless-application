#==============================================================
# OUTPUT BASE DE DATOS
#==============================================================

    output "db_endpoint" {
        description = "El endpoint (DNS Address) de la base de datos RDS (PostgreSQL)."
        # Asumimos que la instancia RDS se llama 'app_db_instance' en el main.tf de la DB
        value       = aws_db_instance.app_db_instance.address
    }

    output "db_name" {
        description = "El ID del Security Group asignado a la instancia RDS."
        value       = aws_db_instance.app_db_instance.db_name
    }

    output "db_id" {
        description = "El ID del Security Group asignado a la instancia RDS."
        value       = aws_db_instance.app_db_instance.id
    }

    output "rds_secret_arn" {
        description = "ARN del Secreto de RDS en Secrets Manager"
        # Referencia el secreto creado en main.tf de este modulo
        value       = aws_secretsmanager_secret.rds_credentials.arn 
    }

