#==============================================================
# MÓDULO KMS: Outputs
#==============================================================

output "kms_key_arn" {
  description = "El ARN completo de la clave KMS"
  value       = aws_kms_key.all_key.arn
}

output "kms_key_id" {
  description = "El ID de la clave KMS"
  value       = aws_kms_key.all_key.key_id
}

output "kms_alias_name" {
  description = "El nombre del alias de la clave KMS"
  value       = aws_kms_alias.rds_alias.name
}