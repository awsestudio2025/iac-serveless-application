#==============================================================
# OUTPUT FARGATE
#==============================================================

   output "alb_target_group_arn" {
        description = "El ID del Security Group asignado a la instancia RDS."
        value       = aws_lb_target_group.app_tg.arn
    }
 