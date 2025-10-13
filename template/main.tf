#==============================================================
# 1.INVOCACION MODULO NEWORKING
#==============================================================

    module "networking" {
        source       = "../modules/networking"
        vpc_cidr     = var.virginia_cidr 
        environment  = var.environment
        project_name = var.project_name
        az_count     = var.az_count
    }

#===============================================================
# 2. INVOCACION MODULO BASE DE DATOS
#===============================================================

    module "database" {
        source                                 = "../modules/database"
        environment                            = var.environment
        project_name                           = var.project_name
        engine                                 = var.engine
        engine_version                         = var.engine_version
        skip_final_snapshot                    = var.skip_final_snapshot
        username                               = var.username
        deletion_protection                    = var.deletion_protection              
        backup_retention_period                = var.backup_retention_period
        performance_insights_retention_period  = var.performance_insights_retention_period
        security_group_rds                     = module.networking.rds_sg_id
        subnet_private_ids                     = module.networking.subnet_private_ids
        allocated_storage                      = var.allocated_storage
        instance_class                         = var.instance_class
        kms_key_arn                            = module.kms.kms_key_arn
        kms_key_id                             = module.kms.kms_key_id
        rds_monitoring_role_arn                = module.iam.rds_monitoring_role_arn
    }

#==============================================================
# 3: INVOCACION MODULO ECR
#==============================================================
    
    module "ecr" {
        source       = "../modules/ecr"
        project_name = var.project_name
        environment  = var.environment
    }

#===============================================================
# 4. INVOCACION MODULO ECS FARGATE
#===============================================================

    module "ecs_fargate" {
        source                  = "../modules/ecs-fargate"
        depends_on              = [
            module.database,
            module.networking
        ]

        environment             = var.environment 
        project_name            = var.project_name
        fargate_cpu             = var.fargate_cpu
        fargate_memory          = var.fargate_memory
        desired_task_count      = var.desired_task_count
        app_port                = var.app_port
        secret_arn              = module.database.rds_secret_arn
        ecr_image_url           = module.ecr.ecr_image_url
        aws_vpc_id              = module.networking.vpc_id
        subnet_public_ids       = module.networking.subnet_public_ids
        subnet_private_ids      = module.networking.subnet_private_ids
        alb_sg_id               = module.networking.alb_sg_id
        app_sg_id               = module.networking.app_sg_id
        kms_key_arn             = module.kms.kms_key_arn
        s3_arn                  = module.s3-bucket.s3_bucket_arn
        ecs_execution_role_arn  = module.iam.ecs_execution_role_arn 
        ecs_task_role_arn       = module.iam.ecs_task_role_arn 
    }
#===============================================================
# 5. INVOCACION MODULO S3 BUCKET
#===============================================================

    module "s3-bucket" {
        source                  = "../modules/s3-bucket"
        environment             = var.environment 
        project_name            = var.project_name
        kms_key_arn             = module.kms.kms_key_arn
    }

#===============================================================
# 6. INVOCACION MODULO KMS
#===============================================================

    module "kms" {
        source                  = "../modules/kms"
        environment             = var.environment 
        project_name            = var.project_name
        s3_arn                  = module.s3-bucket.s3_bucket_arn
    }

#===============================================================
# 7. INVOCACION OBSERVABILITY
#===============================================================

    module "observability" {
        source                  = "../modules/observability"
        environment             = var.environment 
        project_name            = var.project_name
        rds_db_instance_id      = module.database.db_id
        alb_target_group_arn    = module.ecs_fargate.alb_target_group_arn
        email_for_notifications = var.email_for_notifications
    }

#===============================================================
# 8. INVOCACION IAM
#===============================================================

    module "iam" {
        source                  = "../modules/iam"
        environment             = var.environment 
        project_name            = var.project_name
        kms_key_arn             = module.kms.kms_key_arn
        kms_key_id              = module.kms.kms_key_id
        rds_secret_arn          = module.database.rds_secret_arn
        s3_arn                  = module.s3-bucket.s3_bucket_arn
    }