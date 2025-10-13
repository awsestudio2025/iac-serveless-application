#==============================================================
# MÓDULO SECRETS MANAGER: Credenciales de RDS
#==============================================================

# 1. Definición del Secreto
# ---------------------------
# Almacena las credenciales de la base de datos de manera segura.
# ECS Fargate usará el ARN de este secreto para inyectar las credenciales
# como variables de entorno en el contenedor.
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.project_name}/${var.environment}/rds-credentials"
  description = "Credenciales de usuario y contraseña para la base de datos RDS de JFC."
  # Utiliza el ID de la clave KMS central para el cifrado del secreto
  kms_key_id  = var.kms_key_id 
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-secret"
    Environment = var.environment
  }
}

# 2. Contenido del Secreto
# --------------------------
# La mayoría de las aplicaciones esperan un formato JSON para credenciales de DB.
resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  # El contenido del secreto es una cadena JSON que contiene las credenciales.
  secret_string = jsonencode({
    username = var.username
    password = var.password
    engine   = var.engine
    
  })
}
