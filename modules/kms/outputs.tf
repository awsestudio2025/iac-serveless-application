#==============================================================
# MÓDULO KMS: Outputs
#==============================================================

output "kms_key_arn" {
  description = "El ARN completo de la clave KMS, necesario para el cifrado de EBS y S3."
  value       = aws_kms_key.all_key.arn
}

output "kms_key_id" {
  description = "El ID de la clave KMS (UUID), necesario para configurar el Launch Template de EC2 y RDS."
  value       = aws_kms_key.all_key.key_id
}

output "kms_alias_name" {
  description = "El nombre del alias de la clave KMS, útil para referencias en políticas."
  value       = aws_kms_alias.rds_alias.name
}