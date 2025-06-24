terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.78.0"
    }
    local = {
      version = "~> 2.4.0"
    }
  }
  required_version = "~> 1.4.0"
}

# Configure the Google Cloud provider
provider "google" {
  credentials = var.sa_key
  project     = var.project_id
  region      = var.location
}