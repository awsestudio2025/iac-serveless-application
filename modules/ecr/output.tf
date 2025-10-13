#==============================================================
# MÓDULO ECR: Outputs
#==============================================================

    # El ARN del repositorio (para políticas de acceso).
    output "repository_arn" {
        description = "El ARN completo del Repositorio ECR."
        value       = aws_ecr_repository.app_repository.arn
    }

    # URI del repositorio (el valor que se inyecta en la Task Definition de Fargate).
    output "ecr_image_url" {
        description = "La URI del Repositorio ECR"
        value       = aws_ecr_repository.app_repository.repository_url
    }
