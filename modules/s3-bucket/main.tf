#==============================================================
# MÓDULO S3 BUCKET
#==============================================================

    resource "aws_s3_bucket" "app" {
        # Nombre unico: debe incluir el ID de la cuenta si es necesario, pero usamos el project_name y environment para la unicidad.
        bucket = "${var.project_name}-${var.environment}-app"

        tags            = {
            Name        = "${var.project_name}-${var.environment}-app"
            Environment = var.environment
        }
    }

    # 2. Configuración de Bloqueo de Acceso Público (Mejor Práctica de Seguridad)
    resource "aws_s3_bucket_public_access_block" "block_public" {
        bucket = aws_s3_bucket.app.id
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
    }

    # 3. Encriptación del Bucket usando KMS (SSE-KMS)
    resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
        bucket = aws_s3_bucket.app.id

        rule {
            apply_server_side_encryption_by_default {
            sse_algorithm     = "aws:kms"
            kms_master_key_id = var.kms_key_arn
            }
        }
    }

    # 4. Versionado (Opcional, pero recomendado)
    resource "aws_s3_bucket_versioning" "versioning" {
        bucket = aws_s3_bucket.app.id
            versioning_configuration {
                status = "Enabled"
            }
    }