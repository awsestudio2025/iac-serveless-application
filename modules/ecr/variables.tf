#==============================================================
# VARIABLES DEL MÓDULO ECR
#==============================================================

    variable "project_name" {
        description = "Nombre del proyecto"
        type        = string
    }

    variable "environment" {
        description = "Entorno de despliegue"
         type        = string
    }