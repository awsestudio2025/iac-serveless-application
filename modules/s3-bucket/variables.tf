variable "project_name" {
  description = "Nombre del proyecto (ej: jfc-e-commerce)."
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (ej: pdn, dev, qa)."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para cifrar el contenido del bucket."
  type        = string
}