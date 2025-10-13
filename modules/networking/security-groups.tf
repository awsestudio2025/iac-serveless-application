# ==============================================================================
# 1. GRUPOS DE SEGURIDAD (SECURITY GROUPS - SGs)
# ==============================================================================

# 1. SG para el ALB (Entrada web)
# Permite tráfico HTTP/HTTPS desde CUALQUIER LUGAR (Internet)

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "${var.project_name}-${var.environment}-alb-sg"

  # INGRESO: Tráfico HTTP desde cualquier lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # EGRESO: Permite todo el tráfico saliente por defecto
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

# ==============================================================================
# 2. SG para las Instancias (Capa de Aplicación)
# Solo permite tráfico desde el ALB y tráfico saliente al exterior (vía NAT)

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "${var.project_name}-${var.environment}-app-sg"

  # INGRESO: SOLO permite el tráfico que viene del ALB
  ingress {
    from_port       = 8080 # Puerto de escucha de la aplicación (ejemplo)
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Referencia al SG del ALB
    description     = "Permitir trafico solo desde el ALB"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-APP_SG"
    Environment = var.environment
    project_name = var.project_name
  }
}

# ==============================================================================
# 1.3. SG para RDS (Capa de Datos)
# Solo permite tráfico de la Capa de Aplicación.

resource "aws_security_group" "rds_sg" {
  # Controla la creación: 1 si es true, 0 si es false
  # count = var.deploy_rds ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  name   = "${var.project_name}-${var.environment}-rds-sg"

  # INGRESO: SOLO permite tráfico desde APP
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Referencia al SG de la App
    description     = "Permitir trafico solo desde la capa de aplicacion"
  }

  # ingress {
  #   from_port   = 5432 # Puerto de PostgreSQL
  #   to_port     = 5432
  #   protocol    = "tcp"
  #   cidr_blocks = ["181.58.39.95/32"] # Ejemplo: ["189.20.10.5/32"]
  #   description = "Acceso temporal para pruebas desde IP local"
  # }
  
  # EGRESO: No se necesita salida, pero se permite tráfico interno a la misma red (práctica común).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.main_vpc.cidr_block}"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-RDS_SG"
    Environment = var.environment
    project_name = var.project_name
  }
}
