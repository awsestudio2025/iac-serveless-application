output "db_endpoint" {
  description = "El endpoint (DNS Address) de la base de datos RDS (PostgreSQL)."
  # Asumimos que la instancia RDS se llama 'app_db_instance' en el main.tf de la DB
  value       = aws_db_instance.app_db_instance.address
}

# output "db_port" {
#   description = "El puerto de la base de datos"
#   value       = aws_db_instance.app_db_instance.port
# }

output "db_name" {
  description = "El ID del Security Group asignado a la instancia RDS."
  value       = aws_db_instance.app_db_instance.db_name
}


# output "secret_arn" {
#   description = "El ARN del Secret Manager que contiene las credenciales de la base de datos, gestionado por RDS."
#   # Esta línea es la clave: extrae el ARN del secret que RDS creó.
#   value       = aws_db_instance.app_db_instance.master_user_secret[0].secret_arn
# }