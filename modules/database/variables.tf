#==============================================================
# VARIABLES DEL MODULO DATABASE
#==============================================================

  variable "environment" {
    description = "ambiente donde se ejecuta el despliegue"
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

  variable "deletion_protection" {
    description = "proteccion terminacion accidental"
    type = bool
  }

  variable "backup_retention_period" {
    description = "periodo de retencion del backup"
    type = number
  }

  variable "instance_class" {
    description = "Tamaño en clase de la instancia"
    type = string
  }

  variable "kms_key_arn" {
    description = "arn de la Kms"
    type = string
  }
  variable "kms_key_id" {
    description = "Id de la kms"
    type        = string
   }

  variable "performance_insights_retention_period" {
    description = "periodo retencion del performance"
    type = number
  }

  variable "security_group_rds" {
    description = "SG del RDS"
    type = string
  }

  variable "subnet_private_ids" {
    description = "IDs Subnet privadas"
    type = list(string)
  }

  variable "rds_monitoring_role_arn" {
    description = "Rol para el monitoreo"
    type = string
  }