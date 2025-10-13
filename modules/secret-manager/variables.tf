#==============================================================
# VARIABLES SECRET MANAGER
#==============================================================

    variable "project_name" {
        description = "Nombre del proyecto"
        type        = string
    }

    variable "environment" {
        description = "Entorno de despliegue"
        type        = string
    }

    variable "username" {
        description = "usuario data conexion BD"
        type = string
    }

    variable "password" {
        description = "Pass data conexion BD"
        type = string
    }

    variable "kms_key_id" {
        description = "Id de la kms"
        type        = string
    }

    variable "engine" {
        description = "Tipo de base de datos"
        type = string
    }
    