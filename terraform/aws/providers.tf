terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
    local = {
      version = "~> 2.4.0"
    }
  }
  required_version = "~> 1.4.0"
}


# Configure the AWS Provider
provider "aws" {
  region     = var.location
  access_key = var.client_id
  secret_key = var.client_secret
}