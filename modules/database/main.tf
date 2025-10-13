#==============================================================
# MÓDULO DATABASE: Configuración de Amazon Aurora Serverless V2
#==============================================================

  resource "aws_db_subnet_group" "db_subnet_group" {
    name       = "${var.project_name}-${var.environment}-db-subnet-group"
    subnet_ids = var.subnet_private_ids
    
    tags   = {
      Name = "${var.project_name}-${var.environment}-db-Subnet-Group"
    }
  }


  resource "aws_db_instance" "app_db_instance" {
    identifier                            = "${var.project_name}-${var.environment}-db-instance"
    engine                                = var.engine
    engine_version                        = var.engine_version
    instance_class                        = var.instance_class 
    allocated_storage                     = 20
    db_name                               = "DBpostgres"
    username                              = var.username
    password                              = var.password
    vpc_security_group_ids                = [var.security_group_rds]
    db_subnet_group_name                  = aws_db_subnet_group.db_subnet_group.name
    storage_encrypted                     = true
    kms_key_id                            = var.kms_key_arn
    multi_az                              = true 
    publicly_accessible                   = false
    performance_insights_enabled          = true
    deletion_protection                   = var.deletion_protection
    performance_insights_retention_period = var.performance_insights_retention_period
    backup_retention_period               = var.backup_retention_period
    skip_final_snapshot                   = var.skip_final_snapshot
    final_snapshot_identifier             = var.skip_final_snapshot ? null : "final-${var.project_name}-${var.environment}-db-instance-snapshot"
    
    tags = {
      Name        = "${var.project_name}-${var.environment}-AppDB-Instance"
    }
  }