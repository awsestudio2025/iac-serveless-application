#==============================================================
# MÓDULO OBSERVABILITY: Variables de Entrada
#==============================================================

  variable "project_name" {
    description = "Nombre corto del proyecto."
    type        = string
  }

  variable "environment" {
    description = "Entorno de despliegue."
    type        = string
  }

  variable "rds_db_instance_id" {
    description = "El ID de la instancia RDS a monitorear."
    type        = string
  }

  variable "alb_target_group_arn" {
    description = "ARN del Target Group del ALB a monitorear (para latencia/errores)."
    type        = string
  }

  variable "email_for_notifications" {
    description = "Dirección de correo electrónico para recibir notificaciones de alarmas críticas"
    type        = string
  }
