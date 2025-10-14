# ============================================
#    OUTPUTS VPC
# ============================================

output "vpc_id" {
  description = "Security Group de EC2/ASG"
  value = aws_vpc.main_vpc.id
}

# ============================================
#   OUTPUTS SUBNETS
# ============================================

# Subnets publica ALB - App (EC2/ASG) - NAT
output "subnet_public_ids" {
  description = "ids subnet publica"
  value = aws_subnet.public[*].id
}

# Subnets privadas App (EC2/ASG)
output "subnet_private_ids" {
  description = "ids subnet privada EC2/ASG"
  value = aws_subnet.private[*].id
}

# ============================================
#    OUTPUTS SECURITY GROUPS
# ============================================

# Security Group de ALB
output "alb_sg_id" {
  description = "Security Group de EC2/ASG"
  value = aws_security_group.alb_sg.id
}

# Security Group de EC2/ASG
output "app_sg_id" {
  description = "Security Group de EC2/ASG"
  value = aws_security_group.app_sg.id
}

# Security Group de RDS
output "rds_sg_id" {
  description = "Security Group de RDS"
  value = aws_security_group.rds_sg.id
}