
#==============================================================
# MODULO NETWORKING
#==============================================================

  data "aws_availability_zones" "available" {
    state = "available"
  }

  locals {
    azs     = slice(data.aws_availability_zones.available.names, 0, var.az_count)
    newbits = 8
  }

  # PRINCIPAL: VPC
  # ------------------------------
  
  resource "aws_vpc" "main_vpc" {
    cidr_block           = var.vpc_cidr  # Rango total de IPs para toda nuestra red (65,536 direcciones).
    enable_dns_support   = true          # Permite resoluciones DNS dentro de la VPC.
    enable_dns_hostnames = true          # Asigna nombres DNS a las instancias EC2.

    tags           = {
      Name         = "${var.project_name}-${var.environment}-vpc"
    }
  }

  # PUERTA DE ENLACE A INTERNET (IGW)
  # -----------------------------------
  resource "aws_internet_gateway" "igw" {
    vpc_id         = aws_vpc.main_vpc.id # Asocia este IGW a la VPC que acabamos de crear.
    
    tags           = {
      Name         = "${var.project_name}-${var.environment}-igw"
    }
  }

  #===================================================================
  # SUBREDES 2 CAPAS APP Y DATOS
  #================================================================
  #===================================================================
  # CAPA PÚBLICA (Web/Data/ALB)
  #     Cálculo y Creación de Subredes Públicas
  #     CIDRs: 10.0.1.0/24 y 10.0.2.0/24
  #===================================================================
  
  resource "aws_subnet" "public" {
    count                   = length(local.azs)
    vpc_id                  = aws_vpc.main_vpc.id
    cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, local.newbits, count.index + 1)
    availability_zone       = local.azs [count.index] # Primera AZ disponible
    map_public_ip_on_launch = true # Importante: Asigna IPs públicas a los recursos lanzados aquí
    
    tags   = {
      Name = "${var.project_name}-${var.environment}-Public-Subnet-${count.index + 1}"
      Tier = "Public"
    }
  }

  # ========================================================================
  # CAPA PRIVADA - APLICACIONES - BASE DEDATOS
  #     Cálculo y Creación de Subredes Privadas de Aplicación (EC2/ASG)
  #     CIDRs: Bloques 10, 11, ...
  #=========================================================================
  
  resource "aws_subnet" "private" {
    count             = length(local.azs)
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, local.newbits, count.index + 10)
    availability_zone = local.azs [count.index]
    
    tags   = {
      Name = "${var.project_name}-${var.environment}-Private-Subnet-${count.index + 1}"
      Tier = "Private"
    }
  }

  #===================================================================================
  # CONFIGURACIÓN DEL NAT GATEWAY (para tráfico de salida de la Capa Privada)
  #===================================================================================

  # Necesita una IP elástica (EIP)
  resource "aws_eip" "nat_eip" {
    tags   = {
      Name = "${var.project_name}-${var.environment}-NAT-EIP"
    }
    depends_on = [aws_internet_gateway.igw]
  }

  # NAT Gateway: Colocado en la Subred Pública de la AZ-A
  resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public[0].id
    
    tags   = {
      Name = "${var.project_name}-${var.environment}-NAT-GW"

    }
    depends_on = [aws_internet_gateway.igw]
  }

  #==============================================================================
  # TABLAS DE RUTAS Y ASOCIACIONES
  #==============================================================================

  #TABLA DE RUTAS PÚBLICA (Para las subredes de ALB y NAT Gateway)
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main_vpc.id
    
    tags = {
      Name = "${var.project_name}-${var.environment}-Public-RT"
    }
  }

  # RUTA PÚBLICA: Tráfico 0.0.0.0/0 (todo) va al IGW
  resource "aws_route" "public_internet_route" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id # El camino hacia Internet
  }

  # ASOCIACIÓN PÚBLICA: Vincula la tabla a ambas subredes públicas.
  resource "aws_route_table_association" "public" {
    count          = length(local.azs)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
  }

  #================================================================================

  # TABLA DE RUTAS PRIVADA - APLICACIONES (Para EC2/ASG)
  resource "aws_route_table" "private" {
    count  = length(local.azs)
    vpc_id = aws_vpc.main_vpc.id
    
    tags   = {
      Name = "${var.project_name}-${var.environment}-RT-App-Private-${count.index + 1}"
    }
  }

  # RUTA PRIVADA APP: Tráfico 0.0.0.0/0 (todo) va al NAT Gateway
  resource "aws_route" "private_nat_route" {
    count                  = length(local.azs)
    route_table_id         = aws_route_table.private[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gw.id
  }

  # ASOCIACIÓN PRIVADA APP: Vincula la tabla a ambas subredes de aplicación.
  resource "aws_route_table_association" "app_private" {
    count          = length(local.azs)
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
  }

