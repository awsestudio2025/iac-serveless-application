#==============================================================
# MÓDULO KMS: Clave de Cifrado Administrada por el Cliente (CMK)
#==============================================================

# Obtiene la información de la cuenta y la región actual para la política
  data "aws_caller_identity" "current" {}
  data "aws_region" "current" {}

# 1. Recurso KMS Key
  resource "aws_kms_key" "all_key" {
    description             = "KMS key para cifrar datos sensibles (S3, RDS y EBS) en el entorno ${var.environment}"
    deletion_window_in_days = 10
    enable_key_rotation     = true
    
    tags   = {
      Name = "${var.project_name}-${var.environment}-all_key"
    }
  }

  resource "aws_kms_alias" "rds_alias" {
    name            = "alias/all-key-${var.environment}"
    target_key_id   = aws_kms_key.all_key.key_id
  }

# 2. Política de Acceso de la Clave (Key Policy)
  resource "aws_kms_key_policy" "all_key_policy" {
    key_id = aws_kms_key.all_key.id
    policy = jsonencode({
      Version = "2012-10-17"
      Id      = "key-default-policy"
      Statement = [
        # Declaración 1: Acceso de Administrador de la Clave (Root y Terraform User)
        {
          Sid       = "Enable IAM User Permissions"
          Effect    = "Allow"
          Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
          Action    = "kms:*"
          Resource  = "*"
        },
        # Declaración 2: Permite a S3 usar la clave para cifrar/descifrar objetos
        {
          Sid       = "Permitir S3 use llave para cifrar/descifrar objetos"
          Effect    = "Allow"
          Principal = { Service = "s3.amazonaws.com" }
          Action    = [ 
            "kms:Encrypt", 
            "kms:Decrypt", 
            "kms:ReEncrypt*", 
            "kms:GenerateDataKey*", 
            "kms:DescribeKey",
            ]
          Resource  = "*"
          Condition = {
            "StringEquals" = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id },
            "ArnLike"      = { "aws:SourceArn" = "${var.s3_arn}/*" }
          }
        },
        # Declaración 3: Permite a RDS usar la clave para cifrar el almacenamiento
        {
          Sid       = "Permitir RDS use llave para cifrar el almacenamiento"
          Effect    = "Allow"
          Principal = { Service = "rds.amazonaws.com" }
          Action    = [ 
            "kms:Encrypt", 
            "kms:Decrypt", 
            "kms:ReEncrypt*", 
            "kms:GenerateDataKey*", 
            "kms:CreateGrant", 
            "kms:DescribeKey",
            ]
          Resource  = "*"
          Condition = { "StringEquals" = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id } }
        },
        # ✅ Declaración 4: Permite que CUALQUIER principal de IAM de la cuenta use la clave (Base para EBS/RDS)
        {
          Sid       = "Permitir IAM use llave para cifrar/descifrar objetos"
          Effect    = "Allow"
          Principal = { AWS = "*" }
          Action    = [ 
            "kms:Encrypt", 
            "kms:Decrypt", 
            "kms:ReEncrypt*", 
            "kms:GenerateDataKey*", 
            "kms:DescribeKey",
            ]
          Resource  = "*"
        },
      ]
    })
  }
