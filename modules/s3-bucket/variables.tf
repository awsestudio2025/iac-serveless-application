#==============================================================
# VARIABLES S3 BUCKET
#==============================================================
    
    variable "project_name" {
        description = "Nombre del proyecto"
        type        = string
    }

    variable "environment" {
        description = "Entorno de despliegue"
        type        = string
    }

    variable "kms_key_arn" {
        description = "ARN de la clave KMS para cifrar el contenido del bucket."
        type        = string
    }