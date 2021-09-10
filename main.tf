provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.57.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

