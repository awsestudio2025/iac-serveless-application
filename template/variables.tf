# ============================================
# 1. VARIABLES GENERALES DEL ENTORNO
# ============================================
  variable "aws_region" {
    description = "Región de AWS donde se desplegará la infraestructura."
    type        = string
  }

  variable "project_name" {
    description = "Nombre del proyecto"
    type        = string
  }

  variable "environment" {
    description = "ambiente que estamos ejecutando"
    type        = string
  }

  variable "tags" {
    description = "Tags generales"
    type        = map(string)
  }

# =====================================================
# 2. VARIABLES RED
# =====================================================

  variable "virginia_cidr" {
    description = "Red entorno VPC"
    type        = string
  }

  variable "az_count" {
    description = "Cantidad de Zonas de disponibilidad"
    type        = number
  }

# =====================================================
# 3. VARIABLES BASE DE DATOS
# =====================================================

  variable "engine" {
    description = "Motor de base de datos"
    type        = string
  }

  variable "engine_version" {
    description = "Version base de datos"
    type        = string
  }

  variable "skip_final_snapshot" {
    description = "Estado de instantanea si se borra base de datos"
    type        = bool
  }

  variable "username" {
    description = "Estado de instantanea final"
    type        = string
    sensitive   = true
  }

  variable "password" {
    description = "pass conexion base de datos "
    type        = string
    sensitive   = true
  }

  variable "deletion_protection" {
    description = "proteccion terminacion BD "
    type        = bool
  }

  variable "backup_retention_period" {
    description = "retencion respaldo BD"
    type        = number
  }

  variable "performance_insights_retention_period" {
    description = "peridd retencion base de datos"
    type        = number
  }

  variable "allocated_storage" {
    description = "cantidad de almacenamiento"
    type        = number
  }

  variable "instance_class" {
    description = "Clase de instancia"
    type        = string
  }

# =====================================================
# 4. VARIABLES APP
# =====================================================

  variable "fargate_cpu" {
    description = "Variable fargate cpu "
    type        = number
  }

  variable "fargate_memory" {
    description = "Variable fargate memory "
    type        = number
  }

  variable "desired_task_count" {
    description = "variable fargate task "
    type        = number
  }

  variable "app_port" {
    description = "Variable fargate puierto"
    type        = number
  }