#==============================================================
# MÓDULO ECR: Definición del Repositorio de Contenedores
#==============================================================

    # Repositorio ECR
    #--------------------------------------------------------------
    resource "aws_ecr_repository" "app_repository" {
        name                 = "${var.project_name}/${var.environment}/app-backend"
        image_tag_mutability = "MUTABLE"
        force_delete         = true

        encryption_configuration {
            encryption_type = "AES256"
        }

        tags   = {
            Name = "${var.project_name}-${var.environment}-App-ECR"
        }
    }

    # permisos usuariospara jalar la imagen

    resource "aws_ecr_repository_policy" "ecr_policy" {
        repository = aws_ecr_repository.app_repository.name

        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
            {
                Sid    = "AllowPull"
                Effect = "Allow"
                Principal = {
                    AWS = "*"
                }
                Action = [
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:BatchCheckLayerAvailability"
                ]
            }
            ]
        })
    }