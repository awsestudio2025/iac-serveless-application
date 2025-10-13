variable "vpc_cidr" {
  description = "Rango de ridecciones IP de nuestra red"
  type = string
}

variable "environment" {
  description = "ambiente donde se ejecuta el despliegue (DEV, PDN,)"
  type = string
}

variable "project_name" {
  description = "nombre del proyecto"
  type = string
}

variable "az_count" {
  description = "Cantidad de Az a desplegar"
  type = number
}
