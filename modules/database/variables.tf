#==============================================================
# VARIABLES DEL MODULO DATABASE
#==============================================================

variable "environment" {
  description = "ambiente donde se ejecuta el despliegue (DEV, PDN,)"
  type = string
}

variable "project_name" {
  description = "nombre del proyecto"
  type = string
}

variable "engine" {
  description = "Tipo de base de datos"
  type = string
}

variable "engine_version" {
  description = "Version de base de datos"
  type = string
}

variable "skip_final_snapshot" {
  description = "Estado de instantanea si se borra base de datos"
  type = bool
}

variable "allocated_storage" {
  description = "Tamaño de la BD"
  type = number
}

variable "username" {
  description = "usuario data conexion BD"
  type = string
}

variable "password" {
  description = "Pass data conexion BD"
  type = string
}

variable "deletion_protection" {
  description = "ID Subnet privada a Data RDS"
  type = bool
}

variable "backup_retention_period" {
  description = "ID Subnet privada a Data RDS"
  type = number
}

variable "instance_class" {
  description = "Tamaño en clase de la instancia"
  type = string
}

variable "kms_key_arn" {
  description = "Kms cifrado para la base de datos"
  type = string
}


variable "performance_insights_retention_period" {
  description = "ID Subnet privada a Data RDS"
  type = number
}

variable "security_group_rds" {
  description = "SG del RDS"
  type = string
}

variable "subnet_private_ids" {
  description = "ID Subnet privada a Data RDS"
  type = list(string)
}

variable "secret_arn" {
  description = "arn completo del secreto de Secrets Manager"
  type        = string
    }