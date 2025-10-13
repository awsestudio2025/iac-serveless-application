#==============================================================
# MÓDULO DATABASE: RDS PostgreSQL Monolítico (HA con Multi-AZ y Secrets Manager)
#==============================================================

# ----------------------------------------------------
# Generación y Almacenamiento de Credenciales Seguras
# ----------------------------------------------------
# Generador de contraseña segura aleatoria (evita exponer la contraseña en el state file)
  resource "random_password" "db_master_password" {
    length           = 16
    special          = true
    override_special = "!@#$%^&*"
    upper            = true
    lower            = true
    numeric          = true
  }

  # Recurso de Secrets Manager para almacenar las credenciales de la DB
  resource "aws_secretsmanager_secret" "rds_credentials" {
    name        = "${var.project_name}/${var.environment}/rds-master-credentials3"
    description = "Credenciales del usuario maestro de la base de datos RDS para ${var.environment}"
  
    kms_key_id  = var.kms_key_id 
    
    tags = {
      Name        = "${var.project_name}-${var.environment}-RDS-Credentials"
    }
  }

  # Versión del secreto (contenido del secreto: JSON con usuario/password/host/port)
  # Depende de aws_db_instance para obtener el host/port.
  resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
    secret_id     = aws_secretsmanager_secret.rds_credentials.id
    secret_string = jsonencode({
      username = var.username
      password = random_password.db_master_password.result
      host     = aws_db_instance.app_db_instance.address
      port     = aws_db_instance.app_db_instance.port
      dbname   = "DBpostgres"
    })
    # Necesita una dependencia explícita para que el host esté disponible
    depends_on = [aws_db_instance.app_db_instance]
  }


  resource "aws_db_subnet_group" "db_subnet_group" {
    name       = "${var.project_name}-${var.environment}-db-subnet-group"
    subnet_ids = var.subnet_private_ids
    
    tags   = {
      Name = "${var.project_name}-${var.environment}-db-Subnet-Group"
    }
  }


  resource "aws_db_instance" "app_db_instance" {
    identifier                            = "${var.project_name}-${var.environment}-db-instance"
    engine                                = var.engine
    engine_version                        = var.engine_version
    instance_class                        = var.instance_class 
    allocated_storage                     = var.allocated_storage
    db_name                               = "DBpostgres"
    username                              = var.username
    password                              = random_password.db_master_password.result 
    vpc_security_group_ids                = [var.security_group_rds]
    db_subnet_group_name                  = aws_db_subnet_group.db_subnet_group.name
    storage_encrypted                     = true
    kms_key_id                            = var.kms_key_arn
    multi_az                              = true 
    publicly_accessible                   = false
    performance_insights_enabled          = true
    deletion_protection                   = var.deletion_protection
    performance_insights_retention_period = var.performance_insights_retention_period
    backup_retention_period               = var.backup_retention_period
    skip_final_snapshot                   = var.skip_final_snapshot
    monitoring_interval                   = 60  
    monitoring_role_arn                   = var.rds_monitoring_role_arn
    
    tags = {
      Name        = "${var.project_name}-${var.environment}-AppDB-Instance"
    }
  }