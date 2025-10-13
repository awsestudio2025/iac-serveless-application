#==============================================================
# ROLES DE IAM PARA ECS FARGATE
#==============================================================

# ROL DE EJECUCIÓN (TASK EXECUTION ROLE)
    # ----------------------------------------
    # Usado por el agente de ECS para: Pull de ECR, Logs en CloudWatch, y leer Secrets Manager.
    resource "aws_iam_role" "ecs_execution_role" {
        name              = "${var.project_name}-${var.environment}-ecs-execution-role"
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
            Name = "${var.project_name}-${var.environment}-ecs-execution-role"
        }
    }

    # 2. POLÍTICA DE EJECUCIÓN ESTÁNDAR
    # ---------------------------------
    # Política administrada por AWS para ECR, CloudWatch Logs, etc.
    resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
        role       = aws_iam_role.ecs_execution_role.name
        policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    }

    # 3. POLÍTICA ADICIONAL: ACCESO A SECRETS MANAGER Y KMS
    # -----------------------------------------------------
    # Documento de política para obtener credenciales de DB cifradas.
    data "aws_iam_policy_document" "secrets_access_policy" {
        statement {
            sid       = "SecretsManagerAccess"
            actions   = ["secretsmanager:GetSecretValue"]
            resources = [var.rds_secret_arn] 
        }

        statement {
            sid       = "KMSDecryptAccess"
            actions   = ["kms:Decrypt"]
            resources = [var.kms_key_arn] 
        }
    }

    # 4. ADJUNCIÓN DE LA POLÍTICA DE SECRETS MANAGER AL ROL DE EJECUCIÓN
    resource "aws_iam_role_policy" "secrets_access_policy" {
        name   = "${var.project_name}-${var.environment}-SecretsAccessPolicy"
        role   = aws_iam_role.ecs_execution_role.id
        policy = data.aws_iam_policy_document.secrets_access_policy.json
    }


    # ----------------------------------------------------------------------------------
# ROLES DE TAREA (TASK ROLE) - USADO POR LA APLICACIÓN MISMA
    # ----------------------------------------------------------------------------------

    # ROL DE TAREA (TASK ROLE)
    # ----------------------------
    # Rol que la aplicacion usa para interactuar con otros servicios de AWS (S3, etc.)
    resource "aws_iam_role" "ecs_task_role" {
        name              = "${var.project_name}-${var.environment}-ecs-task-role"
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
            Name = "${var.project_name}-${var.environment}-ecs-task-role"
        }
    }

    # POLÍTICA PERSONALIZADA DE LA TAREA ECS (Permisos S3 y KMS)
    # --------------------------------------------------------------
    # Esta política se mantiene, ya que es la app la que accede a S3 y usa KMS para S3.
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
        name   = "${var.project_name}-${var.environment}-ECSTaskPolicy"
        role   = aws_iam_role.ecs_task_role.id
        policy = data.aws_iam_policy_document.ecs_task_permissions.json
    }

    # ----------------------------------------------------------------------------------
# ROL PARA MONITOREO MEJORADO DE RDS (RDS Enhanced Monitoring)
    # ----------------------------------------------------------------------------------

    # ROL DE MONITOREO RDS
    # Usado por el servicio RDS para enviar métricas detalladas a CloudWatch Logs.
    resource "aws_iam_role" "rds_monitoring_role" {
        name               = "${var.project_name}-${var.environment}-rds-monitoring-role"
        description        = "Rol de IAM para el Monitoreo Mejorado (Enhanced Monitoring) de RDS."
        assume_role_policy = jsonencode({
            Version = "2012-10-17",
            Statement = [
                {
                    Action = "sts:AssumeRole",
                    Effect = "Allow",
                    Principal = {
                        Service = "monitoring.rds.amazonaws.com" # Servicio de confianza para el monitoreo
                    }
                }
            ]
        })

        tags = {
            Name = "${var.project_name}-${var.environment}-RDS-Monitoring-Role"
        }
    }

    # 8. ADJUNCIÓN DE LA POLÍTICA ADMINISTRADA DE MONITOREO
    # Esta política administrada por AWS contiene todos los permisos necesarios para CloudWatch Logs.
    resource "aws_iam_role_policy_attachment" "rds_monitoring_policy_attachment" {
        role       = aws_iam_role.rds_monitoring_role.name
        policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
    }