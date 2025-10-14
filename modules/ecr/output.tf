#==============================================================
# OUTPUT MÓDULO ECR
#==============================================================

    output "repository_arn" {
        description = "El ARN completo del Repositorio ECR."
        value       = aws_ecr_repository.app_repository.arn
    }

    output "ecr_image_url" {
        description = "La URL del Repositorio ECR"
        value       = aws_ecr_repository.app_repository.repository_url
    }
