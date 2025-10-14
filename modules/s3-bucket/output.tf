#==============================================================
# OUTPUT S3 BUCKET
#==============================================================

    output "s3_bucket_arn" {
        description = "El ARN del Bucket S3"
        value       = aws_s3_bucket.app.arn
    }

    output "s3_bucket_id" {
        description = "El nombre del Bucket S3"
        value       = aws_s3_bucket.app.id
    }
