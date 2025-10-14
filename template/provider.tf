# Define la versión de Terraform y el proveedor de AWS.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Define la región de AWS a usar.
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = var.tags
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
