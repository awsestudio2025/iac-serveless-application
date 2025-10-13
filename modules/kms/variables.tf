variable "environment" {
  description = "ambiente donde se ejecuta el despliegue (DEV, PDN, QA)"
  type = string
}

variable "project_name" {
  description = "nombre del proyecto"
  type = string
}

variable "s3_arn" {
  description = "arn del bucket S3"
  type = string
}

# variable "instance_profile_arn" {
#   description = "arn del instance"
#   type = string
# }