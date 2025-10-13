#==============================================================
# MÓDULO ECS FARGATE: Variables de Entrada
#==============================================================

    variable "project_name" {
        description = "Nombre del proyecto"
        type        = string
    }

    variable "environment" {
        description = "Entorno de despliegue"
        type        = string
    }

    variable "ecr_image_url" {
        description = "URL completa de la imagen de Docker en Amazon ECR"
        type        = string
    }

    variable "fargate_cpu" {
        description = "Asignación de vCPU para la tarea Fargate"
        type        = number
    }

    variable "fargate_memory" {
        description = "Asignación de memoria para la tarea Fargate "
        type        = number
    }

    variable "app_port" {
        description = "Puerto interno en el que la aplicación escucha dentro del contenedor "
        type        = number
    }

    variable "desired_task_count" {
        description = "Número de tareas Fargate deseadas para el servicio ECS."
        type        = number
    }

    variable "aws_vpc_id" {
        description = "ID de la VPC donde se desplegará el cluster."
        type        = string
    }

    variable "subnet_public_ids" {
        description = "IDs de las subredes públicas"
        type        = list(string)
    }

    variable "subnet_private_ids" {
        description = "IDs de las subredes privadas"
        type        = list(string)
    }

    variable "alb_sg_id" {
        description = "ID del Security Group para el ALB."
        type        = string
    }

    variable "app_sg_id" {
        description = "ID del Security Group para el servicio Fargate "
        type        = string
    }

    variable "secret_arn" {
        description = "arn completo del secreto de Secrets Manager"
        type        = string
    }

    variable "kms_key_arn" {
        description = "ARN de la clave KMS"
        type        = string
    }

    variable "s3_arn" {
        description = "arn del bucket S3"
        type        = string
    }
    
    variable "ecs_execution_role_arn" {
        description = "arn del role ejecucion"
        type        = string
    }
    
    variable "ecs_task_role_arn" {
        description = "arn de la tareas"
        type        = string
    }
    
