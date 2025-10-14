terraform {
  backend "s3" {
    bucket         = "iac-serverless-application" 
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  
  }
}