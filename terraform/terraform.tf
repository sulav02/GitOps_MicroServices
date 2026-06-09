terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.49.0"
    }
  }
  
  backend "s3" {
    bucket = "sulav-terraform-backend-bucket"
    key    = "s3-backend"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

