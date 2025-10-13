#==============================================================
# ROLES DE IAM PARA ECS FARGATE
#==============================================================

    resource "aws_iam_role" "ecs_execution_role" {
        name               = "${var.project_name}-${var.environment}-ecs_execution_rol"
        assume_role_policy = jsonencode({
            Version     = "2012-10-17",
            Statement   = [
                {
                    Action    = "sts:AssumeRole",
                    Effect    = "Allow",
                    Principal = {
                        Service = "ecs-tasks.amazonaws.com"
                    }
                }
            ]
        })

        tags = {
            Name = "${var.project_name}-${var.environment}-ecs_execution_rol"
        }
    }

# 2. POLÍTICA DE EJECUCIÓN
# -------------------------
    resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
        role       = aws_iam_role.ecs_execution_role.name
        policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    }

# 3. ROL DE TAREA (TASK ROLE)
# ----------------------------
# Rol que la aplicacion usa para interactuar con otros servicios de AWS (S3, etc.)
    resource "aws_iam_role" "ecs_task_role" {
        name               = "${var.project_name}-${var.environment}-ecs_task_role"
        assume_role_policy = jsonencode({
            Version = "2012-10-17",
            Statement = [
                {
                    Action = "sts:AssumeRole",
                    Effect = "Allow",
                    Principal = {
                        Service = "ecs-tasks.amazonaws.com"
                    }
                }
            ]
        })

        tags     = {
            Name = "${var.project_name}-${var.environment}-ecs_task_role"
        }
    }

# 4. POLÍTICA PERSONALIZADA DE LA TAREA ECS (Permisos S3 y KMS)
# --------------------------------------------------------------
    data "aws_iam_policy_document" "ecs_task_permissions" {
        statement {
            sid       = "PermisosS3"
            actions   = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ]
            resources = [
                var.s3_arn,        # Acceso al nivel del bucket (para ListBucket)
                "${var.s3_arn}/*"  # Acceso a los objetos dentro del bucket (para Get/PutObject)
            ]
        }

        statement {
            # Permiso 2: Uso de la clave KMS para descifrar objetos S3
            sid       = "PermisosKMS"
            actions   = [
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey"
            ]
            # Restringe el uso de permisos SOLAMENTE a la clave que creamos
            resources = [var.kms_key_arn]
        }
    }

    resource "aws_iam_role_policy" "ecs_task_policy" {
        name   = "ecstaskpolicy"
        role   = aws_iam_role.ecs_task_role.id
        policy = data.aws_iam_policy_document.ecs_task_permissions.json
    }

    data "aws_iam_policy_document" "secrets_access_policy" {
        statement {
            sid       = "PermisosSecretManager"
            actions   = ["secretsmanager:GetSecretValue"]
            resources = [var.secret_arn] 
        }

        statement {
            sid       = "PermisosKMSSecreto"
            actions   = ["kms:Decrypt"]
            resources = [var.kms_key_arn] 
        }
    }

    resource "aws_iam_role_policy" "secrets_access_policy" {
        name   = "secretsaccesspolicy"
        role   = aws_iam_role.ecs_execution_role.id
        policy = data.aws_iam_policy_document.secrets_access_policy.json
    }
