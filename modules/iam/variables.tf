#==============================================================
# VARIABLES IAM
#==============================================================

  variable "environment" {
    description = "ambiente donde se ejecuta el despliegue (DEV, PDN,)"
    type = string
  }

  variable "project_name" {
    description = "nombre del proyecto"
    type = string
  }

  variable "kms_key_arn" {
    description = "Kms cifrado para la base de datos"
    type = string
  }
  variable "kms_key_id" {
    description = "Id de la kms"
    type        = string
   }

  variable "rds_secret_arn" {
    description = "arn del secreto de RDS"
    type = string
  }

  variable "s3_arn" {
    description = "arn del bucket S3"
    type = string
  }