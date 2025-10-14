# ============================================
# 1. VARIABLES GENERALES DEL ENTORNO
# ============================================

    aws_region = "us-east-1"  # Región de la red.
    project_name  = "jfc-e-commerce" # Nombre del proyecto.
    environment  = "pdn" # Entorno de la red (dev -qa - pdn )

    tags = {
    enviroment = "pdn"
    owner = "area atencion usuarios"
    IaC  = "Terraform"
    project_name  = "jfc-e-commerce"
    customer  = "JFC"
    }

# =====================================================
# 2. VARIABLES RED
# =====================================================

    virginia_cidr = "10.0.0.0/16" # Rango total de IPs para toda la red en este caso por se /16 (65,536 direcciones).
    az_count  = 2 # Las cantidades de Zonas de disponibilidad varian segun la region

# =====================================================
# 3. VARIABLES BASE DE DATOS
# =====================================================

    engine = "postgres"  # Motor de base de datos.
    engine_version = "17.4"  # Version
    skip_final_snapshot = true # Estado de instantanea final
    username  = "appamin" # Nombre de usuario
    deletion_protection = false # Protection eliminacion accidental BD
    backup_retention_period = 30  # retencion de backup
    performance_insights_retention_period  = 7 # Almacena 7 días de métricas de rendimiento.
    allocated_storage  = 20
    instance_class = "db.t3.micro"

# =====================================================
# 4. VARIABLES ECS
# =====================================================

    fargate_cpu = 512
    fargate_memory = 1024
    desired_task_count = 2
    app_port  = 8080

# =====================================================
# 5. VARIABLES OBSERVABILITY
# =====================================================

    email_for_notifications = "wilmar.velez02@outlook.com"